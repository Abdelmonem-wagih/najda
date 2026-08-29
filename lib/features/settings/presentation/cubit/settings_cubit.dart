import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsState(locale: Locale('ar')));

  Future<void> loadSettings() async {
    final locale = await _repository.getLocale();
    emit(state.copyWith(locale: locale));
  }

  Future<void> updateLocale(Locale locale) async {
    await _repository.setLocale(locale);
    emit(state.copyWith(locale: locale));
  }
}
