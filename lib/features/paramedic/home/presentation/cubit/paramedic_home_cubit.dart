import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:najda/features/paramedic/home/presentation/cubit/paramedic_home_state.dart';

import '../../domain/repositories/paramedic_home_repository.dart';


class AmbulanceHomeCubit extends Cubit<AmbulanceHomeState> {
  final AmbulanceHomeRepository _repository;
  StreamSubscription? _sub1, _sub2;

  AmbulanceHomeCubit({required AmbulanceHomeRepository repository})
      : _repository = repository,
        super(const AmbulanceHomeState());

  void startListening(String ambulanceId) {
    emit(state.copyWith(isLoading: true));
    
    _sub1?.cancel();
    _sub1 = _repository.getAssignedReports(ambulanceId).listen((reports) {
      emit(state.copyWith(assignedReports: reports, isLoading: false));
    });

    _sub2?.cancel();
    _sub2 = _repository.getAssignedEmergencyReports(ambulanceId).listen((reports) {
      emit(state.copyWith(emergencyReports: reports, isLoading: false));
    });
  }

  Future<void> toggleOnline(String ambulanceId, bool isOnline) async {
    try {
      await _repository.updateOnlineStatus(ambulanceId, isOnline);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub1?.cancel();
    _sub2?.cancel();
    return super.close();
  }
}
