import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:najda/core/constants/app_constants.dart';
import 'package:najda/core/utils/geohash.dart';
import 'package:najda/features/auth/domain/entities/app_user.dart';
import '../models/incident_model.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport({
    required AppUser user,
    required double latitude,
    required double longitude,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReportRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> submitReport({
    required AppUser user,
    required double latitude,
    required double longitude,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  }) async {
    String? imageUrl;
    if (image != null) {
      final ref = _storage.ref(
          'reports/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    final geohash = encodeGeohash(latitude, longitude);

    final incident = IncidentModel(
      id: '', 
      type: 'accident',
      severity: 'medium', // Default for reports, AI will adjust
      status: AppConstants.statusReported,
      reportedBy: user.id,
      reporterPhone: user.phoneNumber,
      reportedAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      location: IncidentLocation(
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        address: '',
      ),
      description: 'Accident Type: $type\nConsciousness: $consciousnessLevel\nInjury: $injuryLocation\nPain: $painLevel',
      reporterMedicalProfile: user.medicalProfile.toMap(),
      reporterEmergencyContact: user.emergencyContactData.toMap(),
      timeline: [
        TimelineEvent(event: 'reported', timestamp: Timestamp.now(), actor: user.id),
      ],
    );

    await _firestore.collection(AppConstants.incidentsCollection).add(incident.toFirestore());
  }
}

