import '../../domain/repositories/sos_repository.dart';
import '../datasources/sos_remote_datasource.dart';
import '../../../../auth/domain/entities/app_user.dart';

class SOSRepositoryImpl implements SOSRepository {
  final SOSRemoteDataSource remoteDataSource;

  SOSRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> triggerSOS({
    required AppUser user,
    required double latitude,
    required double longitude,
  }) {
    return remoteDataSource.triggerSOS(
      user: user,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
