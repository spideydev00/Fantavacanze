import 'package:flutter/material.dart';

class BrandLogoAssets {
  const BrandLogoAssets._();

  static const String _base = 'assets/images/logos';

  static String fvLogo(ThemeMode mode) {
    return mode == ThemeMode.dark
        ? '$_base/logo-neon.png'
        : '$_base/logo-naked.png';
  }

  static String partnerLogo(String slug, ThemeMode mode) {
    return mode == ThemeMode.dark
        ? '$_base/$slug.png'
        : '$_base/$slug-naked.png';
  }
}
