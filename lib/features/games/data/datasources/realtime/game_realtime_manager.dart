import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/game_player_model.dart';
import 'package:fantavacanze_official/features/games/data/models/game_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<GamePlayerModel> applyPlayerDelta(
  List<Map<String, dynamic>> current,
  String op,
  Map<String, dynamic>? record,
  Map<String, dynamic>? oldRecord,
) {
  return _playerModelsFromMaps(
    _applyPlayerMapDelta(current, op, record, oldRecord),
  );
}

Set<String> onlineUserIdsFromPresencePayloads(
  Iterable<Map<String, dynamic>> payloads,
) {
  return {
    for (final payload in payloads)
      if (payload['user_id'] case final String userId) userId,
  };
}

/// Broadcast messages arrive wrapped as `{ event, type, payload: {...} }`.
/// `realtime.broadcast_changes` puts the row change (`table` / `operation` /
/// `record` / `old_record`) inside that inner `payload`. Returns the inner
/// data map, or null if the envelope has no payload.
Map<String, dynamic>? broadcastChangeData(Map<String, dynamic> message) {
  return _payloadMap(message['payload']) ??
      (message.containsKey('table')
          ? Map<String, dynamic>.from(message)
          : null);
}

GameSessionModel? sessionModelFromBroadcastChange(Map<String, dynamic> data) {
  final operation = (data['operation'] ?? data['eventType']) as String;
  final record = _payloadMap(data['record'] ?? data['new']) ??
      _payloadMap(data['old_record'] ?? data['old']);
  if (record == null) {
    return null;
  }

  if (operation == 'DELETE') {
    record['status'] = 'finished';
  }

  return GameSessionModel.fromJson(record);
}

List<Map<String, dynamic>> _applyPlayerMapDelta(
  List<Map<String, dynamic>> current,
  String op,
  Map<String, dynamic>? record,
  Map<String, dynamic>? oldRecord,
) {
  final byId = {
    for (final map in current)
      map['id'] as String: Map<String, dynamic>.from(map),
  };

  switch (op) {
    case 'INSERT':
    case 'UPDATE':
      if (record != null) {
        byId[record['id'] as String] = record;
      }
    case 'DELETE':
      final id = (oldRecord ?? record)?['id'] as String?;
      if (id != null) {
        byId.remove(id);
      }
  }

  final rows = byId.values.toList()
    ..sort((a, b) {
      return DateTime.parse(a['joined_at'] as String).compareTo(
        DateTime.parse(b['joined_at'] as String),
      );
    });
  return rows;
}

List<GamePlayerModel> _playerModelsFromMaps(List<Map<String, dynamic>> maps) {
  return maps.map(GamePlayerModel.fromJson).toList()
    ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
}

Map<String, dynamic>? _payloadMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  return Map<String, dynamic>.from(value);
}

class _SessionChannel {
  _SessionChannel(this.channel);

  final RealtimeChannel channel;
  final sessionCtrl = StreamController<GameSessionModel>.broadcast();
  final playersCtrl = StreamController<List<GamePlayerModel>>.broadcast();
  final presenceCtrl = StreamController<Set<String>>.broadcast();

  int refCount = 0;
  GameSessionModel? lastSession;
  List<GamePlayerModel>? lastPlayers;
  Set<String> lastPresence = const {};
  List<Map<String, dynamic>> playerMaps = [];

  Future<void> close() async {
    await channel.untrack();
    await channel.unsubscribe();
    await sessionCtrl.close();
    await playersCtrl.close();
    await presenceCtrl.close();
  }
}

class GameRealtimeManager {
  GameRealtimeManager({required this.supabaseClient});

  final SupabaseClient supabaseClient;
  final Map<String, _SessionChannel> _channels = {};
  final Map<String, Future<_SessionChannel>> _pendingChannels = {};

  Stream<GameSessionModel> sessionStream({required String sessionId}) {
    return _bind(
      sessionId,
      (session) => session.sessionCtrl.stream,
      (session) => session.lastSession,
    );
  }

  Stream<List<GamePlayerModel>> playersStream({required String sessionId}) {
    return _bind(
      sessionId,
      (session) => session.playersCtrl.stream,
      (session) => session.lastPlayers,
    );
  }

  Stream<Set<String>> presenceStream({required String sessionId}) {
    return _bind(
      sessionId,
      (session) => session.presenceCtrl.stream,
      (session) => session.lastPresence,
    );
  }

  Future<void> dispose(String sessionId) async {
    final session = _channels.remove(sessionId);
    if (session != null) {
      await session.close();
    }
  }

  String _topic(String sessionId) => 'game:$sessionId';

  Future<_SessionChannel> _ensure(String sessionId) async {
    final existing = _channels[sessionId];
    if (existing != null) {
      existing.refCount++;
      return existing;
    }

    final pending = _pendingChannels[sessionId];
    if (pending != null) {
      final session = await pending;
      session.refCount++;
      return session;
    }

    final future = _openChannel(sessionId);
    _pendingChannels[sessionId] = future;
    try {
      return await future;
    } finally {
      _pendingChannels.remove(sessionId);
    }
  }

  Future<_SessionChannel> _openChannel(String sessionId) async {
    try {
      await supabaseClient.realtime.setAuth(
        supabaseClient.auth.currentSession?.accessToken,
      );

      final channel = supabaseClient.channel(
        _topic(sessionId),
        opts: const RealtimeChannelConfig(private: true),
      );
      final session = _SessionChannel(channel)..refCount = 1;
      _channels[sessionId] = session;

      channel
          .onBroadcast(
              event: 'INSERT',
              callback: (payload) {
                _routeChange(session, payload);
              })
          .onBroadcast(
              event: 'UPDATE',
              callback: (payload) {
                _routeChange(session, payload);
              })
          .onBroadcast(
              event: 'DELETE',
              callback: (payload) {
                _routeChange(session, payload);
              })
          .onPresenceSync((_) {
        _emitPresence(session);
      }).subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          unawaited(_seedAndTrack(sessionId, session));
        } else if (status == RealtimeSubscribeStatus.channelError ||
            status == RealtimeSubscribeStatus.timedOut) {
          _addError(session, error ?? 'Connessione realtime non riuscita.');
        }
      });

      return session;
    } catch (e) {
      _channels.remove(sessionId);
      throw ServerException(
        'Impossibile connettersi al canale di gioco: ${e.toString()}',
      );
    }
  }

  Future<void> _seedAndTrack(
    String sessionId,
    _SessionChannel session,
  ) async {
    try {
      await _seed(sessionId, session);
      await session.channel.track({
        'user_id': supabaseClient.auth.currentUser?.id,
        'online_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _addError(session, e);
    }
  }

  void _routeChange(
    _SessionChannel session,
    Map<String, dynamic> message,
  ) {
    // Unwrap the broadcast envelope: row data lives under message['payload'].
    final data = broadcastChangeData(message);
    if (data == null) {
      return;
    }
    if (data['table'] == 'game_sessions') {
      _onSession(session, data);
    } else if (data['table'] == 'game_players') {
      _onPlayer(session, data);
    }
  }

  void _onSession(
    _SessionChannel session,
    Map<String, dynamic> data,
  ) {
    final model = sessionModelFromBroadcastChange(data);
    if (model == null) {
      return;
    }
    session.lastSession = model;
    session.sessionCtrl.add(model);
  }

  void _onPlayer(
    _SessionChannel session,
    Map<String, dynamic> data,
  ) {
    final operation = (data['operation'] ?? data['eventType']) as String;
    final record = _payloadMap(data['record'] ?? data['new']);
    final oldRecord = _payloadMap(data['old_record'] ?? data['old']);

    session.playerMaps = _applyPlayerMapDelta(
      session.playerMaps,
      operation,
      record,
      oldRecord,
    );
    final players = _playerModelsFromMaps(session.playerMaps);
    session.lastPlayers = players;
    session.playersCtrl.add(players);
  }

  void _emitPresence(_SessionChannel session) {
    final payloads = <Map<String, dynamic>>[
      for (final state in session.channel.presenceState())
        for (final presence in state.presences)
          Map<String, dynamic>.from(presence.payload),
    ];
    final ids = onlineUserIdsFromPresencePayloads(payloads);
    session.lastPresence = ids;
    session.presenceCtrl.add(ids);
  }

  Future<void> _seed(String sessionId, _SessionChannel session) async {
    final sessionRow = await supabaseClient
        .from('game_sessions')
        .select()
        .eq('id', sessionId)
        .maybeSingle();

    if (sessionRow != null) {
      final model = GameSessionModel.fromJson(sessionRow);
      session.lastSession = model;
      session.sessionCtrl.add(model);
    }

    final playerRows = await supabaseClient
        .from('game_players')
        .select('*, profiles(name)')
        .eq('session_id', sessionId);

    session.playerMaps = [
      for (final row in playerRows) Map<String, dynamic>.from(row),
    ];
    final players = _playerModelsFromMaps(session.playerMaps);
    session.lastPlayers = players;
    session.playersCtrl.add(players);
  }

  Stream<T> _bind<T>(
    String sessionId,
    Stream<T> Function(_SessionChannel session) pick,
    T? Function(_SessionChannel session) latest,
  ) {
    late StreamController<T> out;
    StreamSubscription<T>? inner;
    _SessionChannel? session;

    out = StreamController<T>(
      onListen: () async {
        try {
          session = await _ensure(sessionId);
          inner = pick(session!).listen(out.add, onError: out.addError);
          final cached = latest(session!);
          if (cached != null) {
            out.add(cached);
          }
        } on ServerException catch (e) {
          out.addError(e);
          await out.close();
        }
      },
      onCancel: () async {
        await inner?.cancel();
        if (session != null) {
          await _release(sessionId);
        }
      },
    );
    return out.stream;
  }

  Future<void> _release(String sessionId) async {
    final session = _channels[sessionId];
    if (session == null) {
      return;
    }

    session.refCount--;
    if (session.refCount <= 0) {
      _channels.remove(sessionId);
      await session.close();
    }
  }

  void _addError(_SessionChannel session, Object error) {
    final exception = error is ServerException
        ? error
        : ServerException(
            'Errore realtime gioco: ${error.toString()}',
          );
    session.sessionCtrl.addError(exception);
    session.playersCtrl.addError(exception);
    session.presenceCtrl.addError(exception);
  }
}
