import '../../../../citizen/report/data/models/incident_model.dart';
import '../../domain/repositories/paramedic_home_repository.dart';
import '../datasources/paramedic_home_remote_datasource.dart';

class AmbulanceHomeRepositoryImpl implements AmbulanceHomeRepository {
  final AmbulanceHomeRemoteDataSource remoteDataSource;

  AmbulanceHomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<IncidentModel>> getAssignedReports(String ambulanceId) {
    return remoteDataSource.getAssignedReports(ambulanceId);
  }

  @override
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String ambulanceId) {
    return remoteDataSource.getAssignedEmergencyReports(ambulanceId);
  }

  @override
  Future<void> updateOnlineStatus(String ambulanceId, bool isOnline) {
    return remoteDataSource.updateOnlineStatus(ambulanceId, isOnline);
  }
}
