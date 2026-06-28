import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrandAssets.logoFor', () {
    test('InVibe: variante dark/light', () {
      expect(
        BrandAssets.logoFor('invibe', isDark: true),
        'assets/images/logos/invibe.png',
      );
      expect(
        BrandAssets.logoFor('invibe', isDark: false),
        'assets/images/logos/invibe-naked.png',
      );
    });

    test('b-eazy: variante dark/light', () {
      expect(
        BrandAssets.logoFor('b-eazy', isDark: true),
        'assets/images/logos/b-eazy.png',
      );
      expect(
        BrandAssets.logoFor('b-eazy', isDark: false),
        'assets/images/logos/b-eazy-naked.png',
      );
    });

    test('null o slug sconosciuto -> null', () {
      expect(BrandAssets.logoFor(null, isDark: true), isNull);
      expect(BrandAssets.logoFor('sconosciuto', isDark: false), isNull);
    });
  });
}
