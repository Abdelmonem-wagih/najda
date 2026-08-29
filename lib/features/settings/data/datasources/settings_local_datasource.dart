import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _keyLocale = 'app_locale';

  @override
  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale) ?? 'ar';
    return Locale(code);
  }

  @override
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }
}
