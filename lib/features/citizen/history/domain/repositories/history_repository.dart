
import '../../../report/data/models/incident_model.dart';

abstract class HistoryRepository {
  Stream<List<IncidentModel>> getHistoryStream(String uid);
}
