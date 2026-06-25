import 'package:fantavacanze_official/core/theme/brand_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrandThemes.of', () {
    test('ritorna il tema InVibe per lo slug "invibe"', () {
      final theme = BrandThemes.of('invibe');

      expect(theme, isNotNull);
      expect(theme!.slug, 'invibe');
      expect(theme.primary(ThemeMode.dark), const Color(0xFF6AC5E6));
      expect(theme.primary(ThemeMode.light), const Color(0xFF3E94AC));
    });

    test('ritorna il colore foreground/social di b-eazy', () {
      final theme = BrandThemes.of('b-eazy');

      expect(theme, isNotNull);
      expect(theme!.slug, 'b-eazy');
      expect(theme.foreground, const Color(0xFFD55EA4));
      expect(theme.primary(ThemeMode.dark), const Color(0xFFD55EA4));
    });

    test('ritorna null per slug sconosciuto o null', () {
      expect(BrandThemes.of('sconosciuto'), isNull);
      expect(BrandThemes.of(null), isNull);
    });
  });
}
