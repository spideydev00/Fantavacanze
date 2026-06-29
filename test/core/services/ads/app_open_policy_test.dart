import 'package:fantavacanze_official/core/services/ads/app_open_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppOpenPolicy', () {
    AppOpenPolicy make(DateTime Function() now) => AppOpenPolicy(
          now: now,
          minInterval: const Duration(minutes: 4),
          maxAge: const Duration(hours: 4),
        );

    test('senza ad caricato non mostra', () {
      final p = make(() => DateTime(2026));
      expect(p.canShow(isPremium: false, otherAdShowing: false), isFalse);
    });

    test('ad caricato e fresco mostra', () {
      final p = make(() => DateTime(2026, 1, 1, 12));
      p.markLoaded();
      expect(p.canShow(isPremium: false, otherAdShowing: false), isTrue);
    });

    test('ad scaduto (>4h) non mostra', () {
      var now = DateTime(2026, 1, 1, 12);
      final p = make(() => now);
      p.markLoaded();
      now = now.add(const Duration(hours: 4, minutes: 1));
      expect(p.canShow(isPremium: false, otherAdShowing: false), isFalse);
    });

    test('rispetta intervallo tra due show', () {
      var now = DateTime(2026, 1, 1, 12);
      final p = make(() => now);
      p.markLoaded();
      p.markShown();
      p.markLoaded();
      now = now.add(const Duration(minutes: 3));
      expect(p.canShow(isPremium: false, otherAdShowing: false), isFalse);
      now = now.add(const Duration(minutes: 2));
      expect(p.canShow(isPremium: false, otherAdShowing: false), isTrue);
    });

    test('premium o altro ad in corso bloccano', () {
      final p = make(() => DateTime(2026, 1, 1, 12));
      p.markLoaded();
      expect(p.canShow(isPremium: true, otherAdShowing: false), isFalse);
      expect(p.canShow(isPremium: false, otherAdShowing: true), isFalse);
    });
  });
}
