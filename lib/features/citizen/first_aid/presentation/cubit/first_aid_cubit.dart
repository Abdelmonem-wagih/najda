import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/first_aid_repository.dart';
import 'first_aid_state.dart';

class FirstAidCubit extends Cubit<FirstAidState> {
  final FirstAidRepository _repository;

  FirstAidCubit({required FirstAidRepository repository})
      : _repository = repository,
        super(FirstAidInitial());

  Future<void> loadFirstAidItems() async {
    emit(FirstAidLoading());
    try {
      final items = await _repository.getFirstAidItems();
      emit(FirstAidLoaded(items: items));
    } catch (e) {
      emit(FirstAidError(e.toString()));
    }
  }

  void search(String query) {
    if (state is FirstAidLoaded) {
      final currentState = state as FirstAidLoaded;
      emit(FirstAidLoaded(items: currentState.items, query: query));
    }
  }
}
