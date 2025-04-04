// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_state.dart';

class AppThemeCubit extends Cubit<AppThemeState> {
  static const String _prefKey = 'theme_mode';
  final SharedPreferences _prefs;

  AppThemeCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(AppThemeState(ThemeMode.system));

  Future<void> loadTheme() async {
    final savedTheme = _prefs.getString(_prefKey);
    if (savedTheme != null) {
      emit(AppThemeState(_themeFromString(savedTheme)));
    } else {
      // Default to system theme
      emit(AppThemeState(ThemeMode.system));
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    await _prefs.setString(_prefKey, _themeToString(themeMode));
    emit(AppThemeState(themeMode));
  }

  Future<void> toggleTheme() async {
    final currentTheme = state.themeMode;
    ThemeMode newTheme;

    if (currentTheme == ThemeMode.light) {
      newTheme = ThemeMode.dark;
    } else {
      newTheme = ThemeMode.light;
    }

    await setTheme(newTheme);
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      default:
        return 'system';
    }
  }

  ThemeMode _themeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    if (state.themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }
}
