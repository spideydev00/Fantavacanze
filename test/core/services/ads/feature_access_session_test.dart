import 'package:fantavacanze_official/core/services/ads/feature_access_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureAccessSession', () {
    test('isActive false di default', () {
      final s = FeatureAccessSession();
      expect(s.isActive(kFeatureGames), isFalse);
    });

    test('grantForLaunch sblocca finché vive il processo', () {
      final s = FeatureAccessSession();
      s.grantForLaunch(kFeatureGlobalRanking);
      expect(s.isActive(kFeatureGlobalRanking), isTrue);
      expect(s.isActive(kFeatureGames), isFalse);
    });

    test('grantTimed attivo entro la durata, scaduto dopo', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final s = FeatureAccessSession(now: () => now);
      s.grantTimed(kFeatureGames, const Duration(minutes: 15));
      expect(s.isActive(kFeatureGames), isTrue);
      now = now.add(const Duration(minutes: 14, seconds: 59));
      expect(s.isActive(kFeatureGames), isTrue);
      now = now.add(const Duration(seconds: 2));
      expect(s.isActive(kFeatureGames), isFalse);
    });

    test('feature isolate', () {
      final s = FeatureAccessSession();
      s.grantTimed(kFeatureGames, const Duration(minutes: 1));
      expect(s.isActive(kFeatureGlobalRanking), isFalse);
    });
  });
}
