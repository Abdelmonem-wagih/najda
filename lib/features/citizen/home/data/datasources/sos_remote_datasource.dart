import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../../../../core/utils/geohash.dart';
import '../../../report/data/models/incident_model.dart';

abstract class SOSRemoteDataSource {
  Future<String> triggerSOS({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
  });
}

class SOSRemoteDataSourceImpl implements SOSRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> triggerSOS({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
  }) async {
    final docRef = await _firestore.collection('criticals').add({
      // ── Identity ─────────────────────────────────────────────
      'shortId': shortId,
      'incidentType': 'emergency',
      'source': 'sos_button',

      // ── Patient — ALL profile fields ─────────────────────────
      'patientUid': user.id,
      'patientName': user.fullName,
      'nationalId': user.nationalId ?? '',
      'phoneNumber': user.phone ?? '',
      'emergencyContact': user.emergencyContact,
      'bloodType': user.medicalProfile.bloodType ?? '',

      // Medical history
      'chronicDiseases': user.medicalProfile.chronicDiseases,
      'allergies': user.medicalProfile.allergies,
      'currentMedications': user.medicalProfile.currentMeds,
      'additionalInfo': user.medicalProfile.notes ?? '',

      // ── Location — lat, lng AND address ──────────────────────
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,

      // ── Status ───────────────────────────────────────────────
      'status': 'pending',
      'assignedAmbulanceId': null,
      'assignedDriverName': null,
      'assignedVehicleId': null,
      'medicalReportSubmitted': false,

      // ── Timestamps ───────────────────────────────────────────
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}

