import 'package:flutter/material.dart';

@immutable
class BrandTheme {
  final String slug;
  final Color primaryDark;
  final Color primaryLight;
  final Color? foreground;

  const BrandTheme({
    required this.slug,
    required this.primaryDark,
    required this.primaryLight,
    this.foreground,
  });

  Color primary(ThemeMode mode) {
    return mode == ThemeMode.dark ? primaryDark : primaryLight;
  }
}

class BrandThemes {
  const BrandThemes._();

  static const Map<String, BrandTheme> _registry = {
    'invibe': BrandTheme(
      slug: 'invibe',
      primaryDark: Color(0xFF6AC5E6),
      primaryLight: Color(0xFF3E94AC),
    ),
    'b-eazy': BrandTheme(
      slug: 'b-eazy',
      primaryDark: Color(0xFFD55EA4),
      primaryLight: Color(0xFFD55EA4),
      foreground: Color(0xFFD55EA4),
    ),
  };

  static BrandTheme? of(String? slug) {
    return slug == null ? null : _registry[slug];
  }
}
