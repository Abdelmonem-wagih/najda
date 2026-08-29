import '../../../report/data/models/incident_model.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<IncidentModel>> getHistoryStream(String uid) {
    return remoteDataSource.getHistoryStream(uid);
  }
}
