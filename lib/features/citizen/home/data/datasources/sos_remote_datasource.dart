import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../../../../core/utils/geohash.dart';
import '../../../report/data/models/incident_model.dart';

abstract class SOSRemoteDataSource {
  Future<String> triggerSOS({
    required AppUser user,
    required double latitude,
    required double longitude,
  });
}

class SOSRemoteDataSourceImpl implements SOSRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> triggerSOS({
    required AppUser user,
    required double latitude,
    required double longitude,
  }) async {
    final geohash = encodeGeohash(latitude, longitude);
    
    final docRef = await _firestore
        .collection('incidents')
        .add({
      'type': 'sos',
      'severity': 'critical',
      'status': IncidentStatus.reported,
      'reportedBy': user.id,
      'reporterPhone': user.phoneNumber,
      'reportedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'geohash': geohash,
        'address': '', // To be filled by cloud function or reverse geocoding
      },
      'victimCount': 1,
      'reporterMedicalProfile': user.medicalProfile.toMap(),
      'reporterEmergencyContact': user.emergencyContactData.toMap(),
      'timeline': [
        {
          'event': 'reported',
          'timestamp': DateTime.now(),
          'actor': user.id,
        }
      ],
    });
    return docRef.id;
  }
}

