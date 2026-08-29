import '../../domain/entities/hospital.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/hospital_remote_datasource.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDataSource remoteDataSource;

  HospitalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Hospital>> getNearbyHospitals(double lat, double lng) async {
    return await remoteDataSource.getNearbyHospitals(lat, lng);
  }
}
