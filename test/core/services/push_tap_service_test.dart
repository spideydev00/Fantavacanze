import 'package:fantavacanze_official/core/services/push_tap_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushTapService.resolveUrl', () {
    test('accetta un URL https su un host in whitelist', () {
      final uri = PushTapService.resolveUrl({
        'url': 'https://fvstore.it/collections/estate?utm_source=push',
      });
      expect(uri, isNotNull);
      expect(uri!.host, 'fvstore.it');
      expect(uri.queryParameters['utm_source'], 'push');
    });

    test('accetta il sottodominio www dichiarato', () {
      expect(PushTapService.resolveUrl({'url': 'https://www.fvstore.it/'}),
          isNotNull);
    });

    test('rifiuta http in chiaro', () {
      expect(PushTapService.resolveUrl({'url': 'http://fvstore.it/'}), isNull);
    });

    test('rifiuta un host fuori whitelist', () {
      expect(PushTapService.resolveUrl({'url': 'https://fvstore.it.evil.com/'}),
          isNull);
    });

    test('rifiuta una stringa non parsabile', () {
      expect(PushTapService.resolveUrl({'url': 'non un url'}), isNull);
    });

    test('restituisce null se manca la chiave url', () {
      // È il caso delle notifiche delle daily challenge: non devono
      // produrre alcun effetto sul nuovo handler.
      expect(PushTapService.resolveUrl({'type': 'daily_challenge_request'}),
          isNull);
    });

    test('restituisce null su data nullo', () {
      expect(PushTapService.resolveUrl(null), isNull);
    });
  });
}
