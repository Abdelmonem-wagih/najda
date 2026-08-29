import '../entities/hospital.dart';

abstract class HospitalRepository {
  Future<List<Hospital>> getNearbyHospitals(double lat, double lng);
}
