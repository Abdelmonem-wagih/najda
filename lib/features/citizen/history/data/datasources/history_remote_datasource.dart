import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../report/data/models/incident_model.dart';

abstract class HistoryRemoteDataSource {
  Stream<List<IncidentModel>> getHistoryStream(String uid);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<IncidentModel>> getHistoryStream(String uid) {
    return _firestore
        .collection('incidents')
        .where('reportedBy', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList())
        .map((list) {
      list.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return list;
    });
  }
}

