import '../../../../citizen/report/data/models/incident_model.dart';
import '../../domain/repositories/paramedic_home_repository.dart';
import '../datasources/paramedic_home_remote_datasource.dart';

class ParamedicHomeRepositoryImpl implements ParamedicHomeRepository {
  final ParamedicHomeRemoteDataSource remoteDataSource;

  ParamedicHomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<IncidentModel>> getAssignedReports(String paramedicId) {
    return remoteDataSource.getAssignedReports(paramedicId);
  }

  @override
  Stream<List<IncidentModel>> getAssignedEmergencyReports(String paramedicId) {
    return remoteDataSource.getAssignedEmergencyReports(paramedicId);
  }

  @override
  Future<void> updateAvailability(String paramedicId, bool isAvailable) {
    return remoteDataSource.updateAvailability(paramedicId, isAvailable);
  }
}
