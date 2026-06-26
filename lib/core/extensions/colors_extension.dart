import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/theme/brand_colors.dart';
import 'package:fantavacanze_official/core/theme/brand_theme.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ThemeColorsExtension on BuildContext {
  /// Gets current ThemeMode from AppThemeCubit
  ThemeMode get _currentThemeMode {
    return read<AppThemeCubit>().state.themeMode;
  }

  /// App theme colors
  Color get primaryColor => Theme.of(this).colorScheme.primary;

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

  Color brandPrimaryColor(String? slug) {
    final brand = BrandThemes.of(slug);
    if (brand == null) return ColorPalette.primary(_currentThemeMode);
    return brand.primary(_currentThemeMode);
  }

  Color brandForegroundColor(String? slug) {
    final brand = BrandThemes.of(slug);
    return brand?.foreground ?? textPrimaryColor;
  }

  /// Accento partner-aware letto dalla ThemeExtension [BrandColors].
  Color get leagueAccentColor =>
      Theme.of(this).extension<BrandColors>()?.accent ?? secondaryColor;

  /// Primary partner-aware letto dalla ThemeExtension [BrandColors].
  Color get brandColor =>
      Theme.of(this).extension<BrandColors>()?.primary ?? primaryColor;
}
