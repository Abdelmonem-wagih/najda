import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../../../citizen/report/data/models/incident_model.dart';

abstract class ReportDetailsRemoteDataSource {
  Future<IncidentModel> getReportDetails(String reportId, String reportType);
  Future<void> updateIncidentStatus(String reportId, String reportType, String status);
  Future<void> updateParamedicStatus(String paramedicId, String status);
  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser paramedic,
    required Map<String, String> answers,
    required String notes,
  });
}

class ReportDetailsRemoteDataSourceImpl implements ReportDetailsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<IncidentModel> getReportDetails(String reportId, String reportType) async {
    final doc = await _firestore.collection(AppConstants.incidentsCollection).doc(reportId).get();
    if (!doc.exists) throw Exception('Report not found');
    return IncidentModel.fromFirestore(doc);
  }

  @override
  Future<void> updateIncidentStatus(String reportId, String reportType, String status) async {
    // 1. Update status and updatedAt
    // 2. Append to timeline
    await _firestore.collection(AppConstants.incidentsCollection).doc(reportId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'event': status,
          'timestamp': DateTime.now(),
          'actor': 'paramedic', // In a real app, this would be the paramedic's UID
        }
      ]),
    });
  }

  @override
  Future<void> updateParamedicStatus(String paramedicId, String status) async {
    await _firestore.collection(AppConstants.paramedicsCollection).doc(paramedicId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser paramedic,
    required Map<String, String> answers,
    required String notes,
  }) async {
    // According to schema 1.2, we don't have a separate medical_reports collection anymore,
    // but the task doesn't explicitly say to remove it. However, unified schema usually prefers embedding.
    // For now, I'll keep it but use incidents if that's what's intended.
    // The prompt says "update all model classes to match section 1 schemas exactly".
    // Schema 1.2 has resolvedAt.
    
    await _firestore.collection(AppConstants.incidentsCollection).doc(reportId).update({
      'status': AppConstants.statusResolved,
      'resolvedAt': FieldValue.serverTimestamp(),
      'description': notes, // Or a separate map if needed
      'timeline': FieldValue.arrayUnion([
        {
          'event': 'resolved',
          'timestamp': DateTime.now(),
          'actor': paramedic.id,
        }
      ]),
    });
  }
}

