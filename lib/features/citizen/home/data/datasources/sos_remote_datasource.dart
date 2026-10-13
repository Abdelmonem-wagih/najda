import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../../../../core/constants/firestore_contract.dart';

abstract class SOSRemoteDataSource {
  /// [latitude]/[longitude]/[accuracy] are nullable — a report must never be
  /// blocked by GPS failing (see SOSCubit._resolvePosition). The dashboard/
  /// Cloud Functions handle a null-location critical as still-pending until
  /// dispatch has another way to locate the patient (e.g. a callback).
  Future<String> triggerSOS({
    required UserModel user,
    double? latitude,
    double? longitude,
    double? accuracy,
    required String address,
    required String shortId,
  });
}

class SOSRemoteDataSourceImpl implements SOSRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> triggerSOS({
    required UserModel user,
    double? latitude,
    double? longitude,
    double? accuracy,
    required String address,
    required String shortId,
  }) async {
    final docRef = await _firestore.collection(FirestoreCollections.criticals).add({
      // ── Identity ─────────────────────────────────────────────
      IncidentFields.shortId: shortId,
      IncidentFields.incidentType: 'emergency',
      IncidentFields.source: 'sos_button',

      // ── Patient — ALL profile fields ─────────────────────────
      IncidentFields.patientUid: user.id,
      IncidentFields.patientName: user.fullName,
      IncidentFields.nationalId: user.nationalId ?? '',
      IncidentFields.phoneNumber: user.phone ?? '',
      IncidentFields.emergencyContact: user.emergencyContact,
      IncidentFields.emergencyContactName: user.emergencyContactData.name,
      IncidentFields.bloodType: user.medicalProfile.bloodType ?? '',

      // Medical history
      IncidentFields.chronicDiseases: user.medicalProfile.chronicDiseases,
      IncidentFields.allergies: user.medicalProfile.allergies,
      IncidentFields.currentMedications: user.medicalProfile.currentMeds,
      IncidentFields.additionalInfo: user.medicalProfile.notes ?? '',

      // ── Location — may be null; address is best-effort ───────
      IncidentFields.latitude: latitude,
      IncidentFields.longitude: longitude,
      IncidentFields.address: address,
      IncidentFields.accuracy: accuracy,

      // ── Status ───────────────────────────────────────────────
      IncidentFields.status: IncidentStatus.pending,
      IncidentFields.assignedAmbulanceId: null,
      IncidentFields.assignedDriverName: null,
      IncidentFields.assignedVehicleId: null,
      IncidentFields.medicalReportSubmitted: false,

      // ── Timestamps ───────────────────────────────────────────
      IncidentFields.createdAt: FieldValue.serverTimestamp(),
      IncidentFields.updatedAt: FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}

