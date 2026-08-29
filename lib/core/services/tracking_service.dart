import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  StreamSubscription? _positionSub;

  void startTracking(String ambulanceId, String? incidentId) {
    // Cancel existing subscription if any
    stopTracking();

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((pos) => _pushLocation(ambulanceId, incidentId, pos));
  }

  Future<void> _pushLocation(String ambulanceId, String? incidentId, Position pos) async {
    final data = {
      'ambulanceId': ambulanceId,
      'incidentId': incidentId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'heading': pos.heading,
      'speed': pos.speed * 3.6, // m/s → km/h
      'accuracy': pos.accuracy,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      // 1. Write current location to tracking/{ambulanceId}
      await FirebaseFirestore.instance
          .collection('tracking')
          .doc(ambulanceId)
          .set(data, SetOptions(merge: true));

      // 2. Append to path array for breadcrumbs
      await FirebaseFirestore.instance
          .collection('tracking')
          .doc(ambulanceId)
          .update({
        'path': FieldValue.arrayUnion([
          {
            'lat': pos.latitude,
            'lng': pos.longitude,
            'ts': DateTime.now().toIso8601String(),
          }
        ]),
      });
    } catch (e) {
      print('Error pushing location: $e');
    }
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }
}
