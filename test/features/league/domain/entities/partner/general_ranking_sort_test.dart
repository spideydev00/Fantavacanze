import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_sort.dart';
import 'package:flutter_test/flutter_test.dart';

GeneralRankingEntry _e(String name, double pts, double bonus, double malus) {
  return GeneralRankingEntry(
    userId: name,
    name: name,
    points: pts,
    bonusTotal: bonus,
    malusTotal: malus,
    leagueName: 'L',
  );
}

void main() {
  group('sortGeneralRanking', () {
    test('points decide first', () {
      final r = sortGeneralRanking([_e('A', 10, 0, 0), _e('B', 20, 0, 0)]);

      expect(r.map((e) => e.name), ['B', 'A']);
    });

    test('equal points -> more bonus wins', () {
      final r = sortGeneralRanking([
        _e('A', 20, 10, -5),
        _e('B', 20, 30, -5),
      ]);

      expect(r.map((e) => e.name), ['B', 'A']);
    });

    test('equal points and bonus -> fewer |malus| wins', () {
      final r = sortGeneralRanking([
        _e('A', 20, 10, -8),
        _e('B', 20, 10, -2),
      ]);

      expect(r.map((e) => e.name), ['B', 'A']);
    });

    test('full tie -> alphabetical', () {
      final r = sortGeneralRanking([
        _e('Zoe', 20, 10, -2),
        _e('Ann', 20, 10, -2),
      ]);

      expect(r.map((e) => e.name), ['Ann', 'Zoe']);
    });
  });
}
