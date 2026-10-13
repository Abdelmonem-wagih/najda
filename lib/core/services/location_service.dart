import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

/// Paramedic-side: sends GPS to Firestore every 5 seconds.
/// Works in foreground AND background (Android foreground service).
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  StreamSubscription<Position>? _posStream;
  String? _ambulanceId;
  String? _collection;
  bool _isRunning = false;
  Position? _lastPosition;

  // ── Start ────────────────────────────────────────────────────────
  Future<void> startTracking({
    required String ambulanceId,
    required String collection, // 'ambulances'
  }) async {
    if (_isRunning) return;
    _ambulanceId = ambulanceId;
    _collection  = collection;

    // Request permissions
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      debugPrint('[GPS] Permission denied forever');
      return;
    }

    _isRunning = true;

    // Send immediately on login
    await _sendCurrentPosition();

    // Stream: send every time moved 10 meters OR every 5 seconds
    _posStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,           // minimum 10m movement
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'نجدة — يتم مشاركة موقعك',
          notificationTitle: 'نجدة نشط',
          enableWakeLock: true,
        ),
      ),
    ).listen((pos) {
      _lastPosition = pos;
      _sendToFirestore(pos);
    });

    // Also start background service for when app is killed
    await _initBackgroundService(ambulanceId, collection);
    debugPrint('[GPS] Tracking started for $ambulanceId');
  }

  // ── Stop ─────────────────────────────────────────────────────────
  Future<void> stopTracking() async {
    _isRunning = false;
    await _posStream?.cancel();
    _posStream = null;
    final service = FlutterBackgroundService();
    service.invoke('stop');
    debugPrint('[GPS] Tracking stopped');
  }

  // ── Send current position once ────────────────────────────────────
  Future<void> _sendCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      _lastPosition = pos;
      await _sendToFirestore(pos);
    } catch (e) {
      debugPrint('[GPS] Failed to get initial position: $e');
    }
  }

  // ── Write to Firestore ────────────────────────────────────────────
  Future<void> _sendToFirestore(Position pos) async {
    if (_ambulanceId == null || _ambulanceId!.isEmpty || _collection == null) return;
    try {
      // Calculate bearing from last position
      double bearing = 0;
      if (_lastPosition != null &&
          _lastPosition != pos) {
        bearing = _calculateBearing(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }

      await FirebaseFirestore.instance
          .collection(_collection!)
          .doc(_ambulanceId!)
          .update({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'area': '${pos.latitude}, ${pos.longitude}',
        'bearing': bearing, // ← for marker rotation
        'speed': pos.speed, // ← m/s
        'accuracy': pos.accuracy,
        'lastActiveAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[GPS] Firestore update failed: $e');
    }
  }

  // ── Bearing calculation ────────────────────────────────────────────
  double _calculateBearing(
    double lat1, double lng1, double lat2, double lng2) {
    final dLat  = (lat2 - lat1) * pi / 180;
    final dLng  = (lng2 - lng1) * pi / 180;
    final rlat1 = lat1 * pi / 180;
    final rlat2 = lat2 * pi / 180;
    final y = sin(dLng) * cos(rlat2);
    final x = cos(rlat1) * sin(rlat2) -
              sin(rlat1) * cos(rlat2) * cos(dLng);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  // ── Background service setup ──────────────────────────────────────
  Future<void> _initBackgroundService(
      String ambulanceId, String collection) async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundServiceMain,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: 999,
        initialNotificationTitle: 'نجدة — تتبع نشط',
        initialNotificationContent: 'يتم مشاركة موقعك مع المركز',
        autoStartOnBoot: false,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: backgroundServiceMain,
        onBackground: _iosBackgroundHandler,
      ),
    );
    await service.startService();
    service.invoke('init', {
      'ambulanceId': ambulanceId,
      'collection':  collection,
    });
  }
}

// ── Background service entry point (must be top-level) ────────────

@pragma('vm:entry-point')
void backgroundServiceMain(ServiceInstance service) async {
  String? ambulanceId;
  String? collection;

  service.on('init').listen((data) {
    ambulanceId = data?['ambulanceId'] as String?;
    collection  = data?['collection']  as String?;
  });

  service.on('stop').listen((_) => service.stopSelf());

  // Send GPS every 5 seconds
  Timer.periodic(const Duration(seconds: 5), (_) async {
    if (ambulanceId == null || ambulanceId!.isEmpty || collection == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );
      await FirebaseFirestore.instance
          .collection(collection!)
          .doc(ambulanceId!)
          .update({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'area': '${pos.latitude}, ${pos.longitude}',
        'lastActiveAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  });
}

@pragma('vm:entry-point')
Future<bool> _iosBackgroundHandler(ServiceInstance s) async => true;
