import 'package:fantavacanze_official/features/league/data/models/partner/general_ranking_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneralRankingEntryModel.fromJson', () {
    test('parses snake_case RPC payload including bonus/malus', () {
      final json = {
        'userId': 'user-1',
        'name': 'Mario',
        'points': 42,
        'bonus_total': 50,
        'malus_total': -8,
        'league_name': 'InVibe Gallipoli',
      };

      final model = GeneralRankingEntryModel.fromJson(json);

      expect(model.userId, 'user-1');
      expect(model.points, 42.0);
      expect(model.bonusTotal, 50.0);
      expect(model.malusTotal, -8.0);
      expect(model.leagueName, 'InVibe Gallipoli');
    });

    test('defaults bonus/malus to 0 when absent (old payloads)', () {
      final json = {
        'user_id': 'user-2',
        'name': 'Luigi',
        'points': 30,
        'league_name': 'InVibe Pag',
      };

      final model = GeneralRankingEntryModel.fromJson(json);

      expect(model.bonusTotal, 0.0);
      expect(model.malusTotal, 0.0);
    });
  });
}
