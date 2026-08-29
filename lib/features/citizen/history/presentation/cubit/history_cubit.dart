import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;
  StreamSubscription? _subscription;

  HistoryCubit({required HistoryRepository repository})
      : _repository = repository,
        super(HistoryInitial());

  void loadHistory(String uid) {
    emit(HistoryLoading());
    _subscription?.cancel();
    _subscription = _repository.getHistoryStream(uid).listen(
      (reports) {
        emit(HistoryLoaded(reports));
      },
      onError: (e) {
        emit(HistoryError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
