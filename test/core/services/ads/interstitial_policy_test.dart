import 'package:fantavacanze_official/core/services/ads/interstitial_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterstitialPolicy', () {
    test('primo show consentito', () {
      final p = InterstitialPolicy(
        now: () => DateTime(2026),
        minInterval: const Duration(minutes: 2),
        maxPerSession: 5,
      );
      expect(p.canShow(), isTrue);
    });

    test('blocca entro l intervallo, consente dopo', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final p = InterstitialPolicy(
        now: () => now,
        minInterval: const Duration(minutes: 2),
        maxPerSession: 5,
      );
      p.markShown();
      now = now.add(const Duration(minutes: 1));
      expect(p.canShow(), isFalse);
      now = now.add(const Duration(minutes: 1, seconds: 1));
      expect(p.canShow(), isTrue);
    });

    test('cap per sessione', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final p = InterstitialPolicy(
        now: () => now,
        minInterval: const Duration(minutes: 2),
        maxPerSession: 2,
      );
      p.markShown();
      now = now.add(const Duration(minutes: 3));
      p.markShown();
      now = now.add(const Duration(minutes: 3));
      expect(p.canShow(), isFalse);
    });
  });
}
