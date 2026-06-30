import 'package:fantavacanze_official/features/games/data/datasources/realtime/game_realtime_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyPlayerDelta', () {
    final base = [
      {
        'id': 'p1',
        'session_id': 's',
        'user_id': 'u1',
        'name': 'Ann',
        'score': 0,
        'is_ghost': false,
        'has_used_special_ability': false,
        'has_used_ghost_protocol': false,
        'change_category_uses_left': 2,
        'joined_at': '2026-06-30T10:00:00Z',
      },
    ];

    test('INSERT adds a new player', () {
      final out = applyPlayerDelta(
          base,
          'INSERT',
          {
            'id': 'p2',
            'session_id': 's',
            'user_id': 'u2',
            'name': 'Bob',
            'score': 0,
            'is_ghost': false,
            'has_used_special_ability': false,
            'has_used_ghost_protocol': false,
            'change_category_uses_left': 2,
            'joined_at': '2026-06-30T10:01:00Z',
          },
          null);

      expect(out.map((e) => e.id), ['p1', 'p2']);
    });

    test('UPDATE replaces by id', () {
      final out = applyPlayerDelta(
        base,
        'UPDATE',
        {...base.first, 'score': 5},
        null,
      );

      expect(out.single.score, 5);
    });

    test('DELETE removes by old_record id', () {
      final out = applyPlayerDelta(base, 'DELETE', null, {'id': 'p1'});

      expect(out, isEmpty);
    });
  });

  group('onlineUserIdsFromPresencePayloads', () {
    test('deduplicates user ids', () {
      final out = onlineUserIdsFromPresencePayloads([
        {'user_id': 'u1'},
        {'user_id': 'u2'},
        {'user_id': 'u1'},
        {'user_id': null},
      ]);

      expect(out, {'u1', 'u2'});
    });
  });
}
