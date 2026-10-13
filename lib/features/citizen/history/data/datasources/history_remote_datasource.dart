import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../report/data/models/incident_model.dart';

abstract class HistoryRemoteDataSource {
  Stream<List<IncidentModel>> getHistoryStream(String uid);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<IncidentModel>> getHistoryStream(String uid) {
    final controller = StreamController<List<IncidentModel>>();
    final latestData = <String, List<IncidentModel>>{};

    void update() {
      if (controller.isClosed) return;
      final all = latestData.values.expand((e) => e).toList();
      all.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      controller.add(all);
    }

    // 1. Listen to 'incidents' (Accidents/Reports)
    final s1 = _firestore
        .collection('incidents')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .listen((s) {
      latestData['incidents'] =
          s.docs.map((d) => IncidentModel.fromFirestore(d)).toList();
      update();
    }, onError: (e) => controller.addError(e));

    // 2. Listen to 'criticals' (SOS)
    final s2 = _firestore
        .collection('criticals')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .listen((s) {
      latestData['criticals'] =
          s.docs.map((d) => IncidentModel.fromFirestore(d)).toList();
      update();
    }, onError: (e) => controller.addError(e));

    controller.onCancel = () {
      s1.cancel();
      s2.cancel();
    };

    return controller.stream;
  }
}

