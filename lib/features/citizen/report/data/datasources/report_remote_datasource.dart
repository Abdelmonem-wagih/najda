import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:najda/core/constants/app_constants.dart';
import 'package:najda/core/utils/geohash.dart';
import 'package:najda/features/auth/domain/entities/app_user.dart';
import '../models/incident_model.dart';

abstract class ReportRemoteDataSource {
  Future<String> submitReport({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
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
  Future<String> submitReport({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  }) async {
    String? imageUrl;
    if (image != null) {
      try {
        final storageRef = _storage
            .ref()
            .child('incidents')
            .child(user.id)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedBy': user.id},
        );

        final uploadTask = storageRef.putFile(image, metadata);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (storageErr) {
        // Image upload failed — continue without image, don't block the report
        debugPrint('Image upload failed: $storageErr');
        imageUrl = null;
      }
    }

    final docRef = await _firestore.collection('incidents').add({
      // ── Identity ─────────────────────────────────────────────
      'shortId': shortId,
      'incidentType': 'report',
      'source': 'accident_form',

      // ── Reporter info ─────────────────────────────────────────
      'patientUid': user.id,
      'patientName': user.fullName,
      'nationalId': user.nationalId ?? '',
      'phoneNumber': user.phone ?? '',
      'emergencyContact': user.emergencyContact,
      'bloodType': user.medicalProfile.bloodType ?? '',
      'chronicDiseases': user.medicalProfile.chronicDiseases,
      'allergies': user.medicalProfile.allergies,
      'currentMedications': user.medicalProfile.currentMeds,
      'additionalInfo': user.medicalProfile.notes ?? '',

      // ── Accident details (answers) ────────────────────────────
      'accidentType': type,
      'consciousnessLevel': consciousnessLevel ?? '',
      'injuryLocation': injuryLocation ?? '',
      'painLevel': painLevel ?? '',
      'imageUrl': imageUrl ?? '',

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

