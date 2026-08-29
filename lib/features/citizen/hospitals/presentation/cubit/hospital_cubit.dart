import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/hospital_repository.dart';
import 'hospital_state.dart';

class HospitalCubit extends Cubit<HospitalState> {
  final HospitalRepository _repository;

  HospitalCubit({required HospitalRepository repository})
      : _repository = repository,
        super(HospitalInitial());

  Future<void> loadNearbyHospitals() async {
    emit(HospitalLoading());
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        emit(const HospitalError('صلاحية الموقع مرفوضة. فعّلها من الإعدادات.'));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final hospitals = await _repository.getNearbyHospitals(pos.latitude, pos.longitude);
      emit(HospitalLoaded(hospitals: hospitals, position: pos));
    } catch (e) {
      emit(HospitalError(e.toString()));
    }
  }
}
