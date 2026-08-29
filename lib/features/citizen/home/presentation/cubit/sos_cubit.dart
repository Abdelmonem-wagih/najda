import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/sos_repository.dart';
import '../../../../auth/domain/entities/app_user.dart';

part 'sos_state.dart';

class SOSCubit extends Cubit<SOSState> {
  final SOSRepository _repository;

  SOSCubit({required SOSRepository repository})
      : _repository = repository,
        super(SOSInitial());

  Future<void> triggerSOS(AppUser user) async {
    emit(SOSLoading());
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final reportId = await _repository.triggerSOS(
        user: user,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      emit(SOSSuccess(reportId, pos.latitude, pos.longitude));
    } catch (e) {
      emit(SOSError(e.toString()));
    }
  }
}
