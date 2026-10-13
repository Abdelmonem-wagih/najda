import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/firestore_contract.dart';

double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
  final dLng  = (lng2 - lng1) * pi / 180;
  final rlat1 = lat1 * pi / 180;
  final rlat2 = lat2 * pi / 180;
  final y = sin(dLng) * cos(rlat2);
  final x = cos(rlat1) * sin(rlat2) -
            sin(rlat1) * cos(rlat2) * cos(dLng);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

/// Writes exactly the tracking/{ambulanceId} field whitelist firestore.rules
/// enforces ({latitude, longitude, bearing, speed, accuracy, updatedAt},
/// nothing else) — a `.set()` (not merge), since tracking is "one doc per
/// ambulance, latest point only".
Future<void> _writeTrackingPoint({
  required String ambulanceId,
  required double latitude,
  required double longitude,
  required double bearing,
  required double speed,
  required double accuracy,
}) async {
  await FirebaseFirestore.instance
      .collection(FirestoreCollections.tracking)
      .doc(ambulanceId)
      .set({
    TrackingFields.latitude: latitude,
    TrackingFields.longitude: longitude,
    TrackingFields.bearing: bearing,
    TrackingFields.speed: speed,
    TrackingFields.accuracy: accuracy,
    TrackingFields.updatedAt: FieldValue.serverTimestamp(),
  });
}

/// Paramedic-side: sends GPS to tracking/{ambulanceId} every 5 seconds.
/// Works in foreground AND background (Android foreground service).
///
/// Writes ONLY to `tracking/` — never to the ambulance doc itself, which no
/// longer carries position fields at all (lat/lng/latitude/longitude/
/// heading/area/speed/accuracy/lastSeen were all removed from the canonical
/// ambulances schema; `area` in particular used to get silently overwritten
/// with a raw coordinate string by this exact writer every ~5s, destroying
/// the admin-entered zone name). firestore.rules also now rejects any of
/// those fields on an `ambulances` client update, so this isn't optional.
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  StreamSubscription<Position>? _posStream;
  String? _ambulanceId;
  bool _isRunning = false;
  Position? _lastPosition;

  // ── Start ────────────────────────────────────────────────────────
  Future<void> startTracking({required String ambulanceId}) async {
    if (_isRunning) return;
    _ambulanceId = ambulanceId;

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

    // Send immediately on start
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
    await _initBackgroundService(ambulanceId);
    debugPrint('[GPS] Tracking started for $ambulanceId');
  }

  // ── Stop ─────────────────────────────────────────────────────────
  Future<void> stopTracking() async {
    _isRunning = false;
    await _posStream?.cancel();
    _posStream = null;
    _ambulanceId = null;
    _lastPosition = null;
    final service = FlutterBackgroundService();
    service.invoke('stop');
    debugPrint('[GPS] Tracking stopped');
  }

  bool get isRunning => _isRunning;

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

  // ── Write to tracking/{ambulanceId} ────────────────────────────────
  Future<void> _sendToFirestore(Position pos) async {
    final ambulanceId = _ambulanceId;
    if (ambulanceId == null || ambulanceId.isEmpty) return;
    try {
      double bearing = 0;
      if (_lastPosition != null && _lastPosition != pos) {
        bearing = _calculateBearing(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }

      await _writeTrackingPoint(
        ambulanceId: ambulanceId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        bearing: bearing,
        speed: pos.speed,
        accuracy: pos.accuracy,
      );
    } catch (e) {
      debugPrint('[GPS] Firestore update failed: $e');
    }
  }

  // ── Background service setup ──────────────────────────────────────
  Future<void> _initBackgroundService(String ambulanceId) async {
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
    service.invoke('init', {'ambulanceId': ambulanceId});
  }
}

// ── Background service entry point (must be top-level) ────────────

@pragma('vm:entry-point')
void backgroundServiceMain(ServiceInstance service) async {
  String? ambulanceId;
  Position? lastPos;

  service.on('init').listen((data) {
    ambulanceId = data?['ambulanceId'] as String?;
  });

  service.on('stop').listen((_) => service.stopSelf());

  // Send GPS every 5 seconds
  Timer.periodic(const Duration(seconds: 5), (_) async {
    final id = ambulanceId;
    if (id == null || id.isEmpty) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );
      double bearing = 0;
      if (lastPos != null && lastPos != pos) {
        bearing = _calculateBearing(
          lastPos!.latitude, lastPos!.longitude, pos.latitude, pos.longitude,
        );
      }
      lastPos = pos;
      await _writeTrackingPoint(
        ambulanceId: id,
        latitude: pos.latitude,
        longitude: pos.longitude,
        bearing: bearing,
        speed: pos.speed,
        accuracy: pos.accuracy,
      );
    } catch (_) {}
  });
}

@pragma('vm:entry-point')
Future<bool> _iosBackgroundHandler(ServiceInstance s) async => true;
