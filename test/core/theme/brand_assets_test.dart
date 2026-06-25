import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrandAssets.logoFor', () {
    test('ritorna null per slug null o sconosciuto', () {
      expect(BrandAssets.logoFor(null), isNull);
      expect(BrandAssets.logoFor('sconosciuto'), isNull);
    });

    test('ritorna null per InVibe finche asset non e registrato', () {
      expect(BrandAssets.logoFor('invibe'), isNull);
    });
  });
}
