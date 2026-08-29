import 'dart:ui';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Locale> getLocale() {
    return localDataSource.getLocale();
  }

  @override
  Future<void> setLocale(Locale locale) {
    return localDataSource.setLocale(locale);
  }
}
