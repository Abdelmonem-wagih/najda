import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/paramedic_home_repository.dart';
import 'paramedic_home_state.dart';

class ParamedicHomeCubit extends Cubit<ParamedicHomeState> {
  final ParamedicHomeRepository _repository;
  StreamSubscription? _sub1, _sub2;

  ParamedicHomeCubit({required ParamedicHomeRepository repository})
      : _repository = repository,
        super(const ParamedicHomeState());

  void startListening(String paramedicId) {
    emit(state.copyWith(isLoading: true));
    
    _sub1?.cancel();
    _sub1 = _repository.getAssignedReports(paramedicId).listen((reports) {
      emit(state.copyWith(assignedReports: reports, isLoading: false));
    });

    _sub2?.cancel();
    _sub2 = _repository.getAssignedEmergencyReports(paramedicId).listen((reports) {
      emit(state.copyWith(emergencyReports: reports, isLoading: false));
    });
  }

  Future<void> toggleAvailability(String paramedicId, bool isAvailable) async {
    try {
      await _repository.updateAvailability(paramedicId, isAvailable);
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
