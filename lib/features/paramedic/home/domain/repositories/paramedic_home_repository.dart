
import '../../../../citizen/report/data/models/incident_model.dart';

abstract class AmbulanceHomeRepository {
  Stream<List<IncidentModel>> getAssignedReports(String ambulanceId);
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String ambulanceId);
  Future<void> updateOnlineStatus(String ambulanceId, bool isOnline);
}
