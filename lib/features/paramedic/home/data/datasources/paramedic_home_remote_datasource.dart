import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../citizen/report/data/models/incident_model.dart';


abstract class AmbulanceHomeRemoteDataSource {
  Stream<List<IncidentModel>> getAssignedReports(String ambulanceId);
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String ambulanceId);
  Future<void> updateOnlineStatus(String ambulanceId, bool isOnline);
}

class AmbulanceHomeRemoteDataSourceImpl implements AmbulanceHomeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<IncidentModel>> getAssignedReports(String ambulanceId) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .where('assignment.ambulanceId', isEqualTo: ambulanceId)
        .where('type', isEqualTo: 'accident')
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String ambulanceId) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .where('assignment.ambulanceId', isEqualTo: ambulanceId)
        .where('type', isEqualTo: 'sos')
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList());
  }

  @override
  Future<void> updateOnlineStatus(String ambulanceId, bool isOnline) async {
    // The requirement is to use 'isOnline' for connection state and 'status' for operational state.
    // This method is used for toggling online/offline from the UI.
    
    await _firestore
        .collection(AppConstants.ambulancesCollection)
        .doc(ambulanceId)
        .update({
      'isOnline': isOnline,
      'status': 'available', // operational status starts as available
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

