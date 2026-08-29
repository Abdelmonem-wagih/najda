import 'dart:ui';

abstract class SettingsRepository {
  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);
}
