
import '../../../../citizen/report/data/models/incident_model.dart';

abstract class ParamedicHomeRepository {
  Stream<List<IncidentModel>> getAssignedReports(String paramedicId);
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String paramedicId);
  Future<void> updateAvailability(String paramedicId, bool isAvailable);
}
