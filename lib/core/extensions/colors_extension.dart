import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/seasonal_event/seasonal_event_cubit.dart';
import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ThemeColorsExtension on BuildContext {
  /// Gets current ThemeMode from AppThemeCubit
  ThemeMode get _currentThemeMode {
    return read<AppThemeCubit>().state.themeMode;
  }

  /// App theme colors
  Color get primaryColor => ColorPalette.primary(_currentThemeMode);
  Color get secondaryColor => ColorPalette.secondary(_currentThemeMode);
  Color get ternaryColor => ColorPalette.ternary(_currentThemeMode);
  Color get accentColor => ColorPalette.accent(_currentThemeMode);

  /// Text colors
  Color get textPrimaryColor => ColorPalette.textPrimary(_currentThemeMode);
  Color get textSecondaryColor => ColorPalette.textSecondary(_currentThemeMode);

  /// Background colors
  Color get bgColor => ColorPalette.bgColor(_currentThemeMode);
  Color get secondaryBgColor =>
      ColorPalette.secondaryBgColor(_currentThemeMode);

  /// Border colors
  Color get borderColor => ColorPalette.borderColor(_currentThemeMode);
}

extension ColorsExtension on BuildContext {
  /// Get current seasonal gradient colors
  List<Color> get seasonalGradient {
    try {
      final seasonalState = read<SeasonalEventCubit>().state;
      return ColorPalette.getSeasonalGradient(seasonalState.activeNightType);
    } catch (e) {
      // Fallback to default FS gradient if cubit not found
      return ColorPalette.fsGradients;
    }
  }

  /// Get seasonal gradient as LinearGradient
  LinearGradient get seasonalLinearGradient {
    try {
      final seasonalState = read<SeasonalEventCubit>().state;
      return ColorPalette.getSeasonalLinearGradient(
        seasonalState.activeNightType,
      );
    } catch (e) {
      // Fallback to default FS gradient
      return LinearGradient(colors: ColorPalette.fsGradients);
    }
  }

  /// Check if a specific night type is currently active
  bool isNightTypeActive(FsNightType nightType) {
    try {
      return read<SeasonalEventCubit>().isNightTypeActive(nightType);
    } catch (e) {
      return false;
    }
  }

  /// Get current night type
  FsNightType get currentNightType {
    try {
      return read<SeasonalEventCubit>().currentNightType;
    } catch (e) {
      return FsNightType.def;
    }
  }
}
