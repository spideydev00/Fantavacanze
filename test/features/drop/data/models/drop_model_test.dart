import 'package:fantavacanze_official/features/drop/data/models/drop_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropModel', () {
    const imageUrls = [
      'https://esempio/estate-2026-1.png',
      'https://esempio/estate-2026-2.png',
      'https://esempio/estate-2026-3.png',
    ];
    const imageDescriptions = [
      'Maglietta nera',
      'Felpa bianca',
      'Cappellino nero',
    ];

    test('fa il parsing delle tre immagini del drop', () {
      final model = DropModel.fromJson({
        'code': 'estate-2026',
        'image_urls': imageUrls,
        'image_descriptions': imageDescriptions,
        'cta_label': 'Scopri il drop',
        'cta_url': 'https://fvstore.it/collections/estate',
      });

      expect(model.code, 'estate-2026');
      expect(model.imageUrls, imageUrls);
      expect(model.imageUrls, hasLength(3));
      expect(model.imageDescriptions, imageDescriptions);
      expect(model.ctaLabel, 'Scopri il drop');
      expect(model.ctaUrl, 'https://fvstore.it/collections/estate');
    });

    test('espone una lista di immagini immutabile', () {
      final model = DropModel.fromJson({
        'code': 'estate-2026',
        'image_urls': imageUrls,
        'image_descriptions': imageDescriptions,
        'cta_label': 'Scopri il drop',
        'cta_url': 'https://fvstore.it/collections/estate',
      });

      expect(
        () => model.imageUrls.add('https://esempio/extra.png'),
        throwsUnsupportedError,
      );
    });

    test('rifiuta un drop che non contiene tre immagini', () {
      expect(
        () => DropModel.fromJson({
          'code': 'estate-2026',
          'image_urls': imageUrls.take(2).toList(),
          'image_descriptions': imageDescriptions,
          'cta_label': 'Scopri il drop',
          'cta_url': 'https://fvstore.it/collections/estate',
        }),
        throwsFormatException,
      );
    });

    test('rifiuta tre immagini non distinte', () {
      expect(
        () => DropModel.fromJson({
          'code': 'estate-2026',
          'image_urls': [imageUrls.first, imageUrls.first, imageUrls.last],
          'image_descriptions': imageDescriptions,
          'cta_label': 'Scopri il drop',
          'cta_url': 'https://fvstore.it/collections/estate',
        }),
        throwsFormatException,
      );
    });

    test('rifiuta descrizioni mancanti o vuote', () {
      expect(
        () => DropModel.fromJson({
          'code': 'estate-2026',
          'image_urls': imageUrls,
          'image_descriptions': ['Maglietta nera', '', 'Cappellino nero'],
          'cta_label': 'Scopri il drop',
          'cta_url': 'https://fvstore.it/collections/estate',
        }),
        throwsFormatException,
      );
    });
  });
}
