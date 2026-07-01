import 'package:fantavacanze_official/features/games/data/datasources/realtime/game_realtime_manager.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
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

  group('broadcastChangeData', () {
    test('unwraps row data from the broadcast envelope', () {
      // Shape delivered by realtime_client onBroadcast: the whole message,
      // with the broadcast_changes row data nested under `payload`.
      final message = {
        'event': 'UPDATE',
        'type': 'broadcast',
        'payload': {
          'schema': 'public',
          'table': 'game_sessions',
          'operation': 'UPDATE',
          'record': {'id': 's1', 'status': 'in_progress'},
          'old_record': {'id': 's1', 'status': 'waiting'},
        },
      };

      final data = broadcastChangeData(message);

      expect(data, isNotNull);
      expect(data!['table'], 'game_sessions');
      expect(data['operation'], 'UPDATE');
      expect((data['record'] as Map)['status'], 'in_progress');
    });

    test('returns null when the envelope has no payload', () {
      expect(broadcastChangeData({'event': 'UPDATE', 'type': 'broadcast'}),
          isNull);
    });

    test('accepts direct row change payloads', () {
      final data = broadcastChangeData({
        'schema': 'public',
        'table': 'game_players',
        'operation': 'INSERT',
        'record': {'id': 'p1'},
      });

      expect(data, isNotNull);
      expect(data!['table'], 'game_players');
      expect((data['record'] as Map)['id'], 'p1');
    });
  });

  group('sessionModelFromBroadcastChange', () {
    test('maps DELETE old_record to a finished session update', () {
      final session = sessionModelFromBroadcastChange({
        'schema': 'public',
        'table': 'game_sessions',
        'operation': 'DELETE',
        'old_record': {
          'id': 's1',
          'invite_code': 'ABC1234',
          'admin_id': 'u1',
          'game_type': 'truth_or_dare',
          'status': 'in_progress',
          'current_turn_user_id': 'u2',
          'game_state': null,
          'created_at': '2026-06-30T10:00:00Z',
        },
      });

      expect(session, isNotNull);
      expect(session!.status, GameStatus.finished);
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
