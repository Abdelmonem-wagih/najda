import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../citizen/report/data/models/incident_model.dart';


abstract class ParamedicHomeRemoteDataSource {
  Stream<List<IncidentModel>> getAssignedReports(String paramedicId);
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String paramedicId);
  Future<void> updateAvailability(String paramedicId, bool isAvailable);
}

class ParamedicHomeRemoteDataSourceImpl implements ParamedicHomeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<IncidentModel>> getAssignedReports(String paramedicId) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .where('assignment.paramedicId', isEqualTo: paramedicId)
        .where('type', isEqualTo: 'accident')
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String paramedicId) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .where('assignment.paramedicId', isEqualTo: paramedicId)
        .where('type', isEqualTo: 'sos')
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList());
  }

  @override
  Future<void> updateAvailability(String paramedicId, bool isAvailable) async {
    await _firestore
        .collection(AppConstants.paramedicsCollection)
        .doc(paramedicId)
        .update({
      'status': isAvailable ? 'active' : 'inactive',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

