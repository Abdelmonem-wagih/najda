import '../../domain/repositories/sos_repository.dart';
import '../datasources/sos_remote_datasource.dart';
import '../../../../auth/domain/entities/app_user.dart';

class SOSRepositoryImpl implements SOSRepository {
  final SOSRemoteDataSource remoteDataSource;

  SOSRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> triggerSOS({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
  }) {
    return remoteDataSource.triggerSOS(
      user: user,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
      shortId: shortId,
    );
  }
}
