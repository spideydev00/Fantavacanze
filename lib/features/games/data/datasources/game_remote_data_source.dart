import 'dart:async';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/game_player_model.dart';
import 'package:fantavacanze_official/features/games/data/models/game_session_model.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class GameRemoteDataSource {
  Future<GameSessionModel> createGameSession({
    required String adminId,
    required GameType gameType,
    required String userName,
  });

  Future<GameSessionModel> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<bool> leaveGameSession({
    required String sessionId,
    required String userId,
  });

  Stream<GameSessionModel> streamGameSession({
    required String sessionId,
  });

  Stream<List<GamePlayerModel>> streamLobbyPlayers({
    required String sessionId,
  });

  Future<GameSessionModel> updateGameState({
    required String sessionId,
    Map<String, dynamic>? newGameState,
    String? currentTurnUserId,
    String? status,
  });

  Future<GamePlayerModel> updateGamePlayer({
    required String playerId,
    required String sessionId,
    required String userId,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft,
  });

  Future<void> updateGamePlayerNameInLobbyDb({
    required String playerId,
    required String newName,
  });

  Future<void> removeGamePlayerFromLobbyDb({
    required String playerId,
    required String sessionId,
  });

  Future<void> killSession({required String sessionId});
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final SupabaseClient supabaseClient;

  GameRemoteDataSourceImpl({required this.supabaseClient});

  // =====================================================================
  // ERROR HANDLING UTILITIES
  // =====================================================================

  // ------------------ EXTRACT ERROR MESSAGE ------------------ //
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  // ------------------ TRY DATABASE OPERATION ------------------ //
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // =====================================================================
  // SESSION MANAGEMENT
  // =====================================================================

  // ------------------ CREATE GAME SESSION ------------------ //
  @override
  Future<GameSessionModel> createGameSession({
    required String adminId,
    required String userName,
    required GameType gameType,
  }) async {
    return _tryDatabaseOperation(() async {
      final params = {
        'p_admin_id': adminId,
        'p_user_name': userName,
        'p_game_type': gameTypeToString(gameType),
      };

      final response = await supabaseClient
          .rpc('create_session_and_add_admin', params: params)
          .single();

      final gameSession = GameSessionModel.fromJson(response);

      return gameSession;
    });
  }

  // ------------------ JOIN GAME SESSION ------------------ //
  @override
  Future<GameSessionModel> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    return _tryDatabaseOperation(() async {
      final params = {
        'p_invite_code': inviteCode.toUpperCase(),
        'p_user_id': userId,
        'p_user_name': userName,
      };

      final response =
          await supabaseClient.rpc('join_session', params: params).single();

      return GameSessionModel.fromJson(response);
    });
  }

  // ------------------ LEAVE GAME SESSION ------------------ //
  @override
  Future<bool> leaveGameSession({
    required String sessionId,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      final result = await supabaseClient.rpc(
        'leave_game_session',
        params: {'p_session_id': sessionId, 'p_user_id': userId},
      );
      return result as bool;
    });
  }

  // ------------------ STREAM GAME SESSION ------------------ //
  @override
  Stream<GameSessionModel> streamGameSession({required String sessionId}) {
    try {
      return supabaseClient
          .from('game_sessions')
          .stream(primaryKey: ['id'])
          .eq('id', sessionId)
          .map(
            (maps) {
              if (maps.isEmpty) {
                throw ServerException('Sessione non trovata o accesso negato.');
              }
              return GameSessionModel.fromJson(maps.first);
            },
          );
    } catch (e) {
      throw ServerException(
          'Errore nello streaming della sessione: ${_extractErrorMessage(e)}');
    }
  }

  // ------------------ KILL SESSION ------------------ //
  @override
  Future<void> killSession({required String sessionId}) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient.rpc(
        'kill_game_session',
        params: {'session_id_to_delete': sessionId},
      );
    });
  }

  // =====================================================================
  // PLAYER MANAGEMENT
  // =====================================================================

  // ------------------ STREAM LOBBY PLAYERS ------------------ //
  @override
  Stream<List<GamePlayerModel>> streamLobbyPlayers(
      {required String sessionId}) {
    try {
      return supabaseClient
          .from('game_players')
          .stream(primaryKey: ['id'])
          .eq('session_id', sessionId)
          .map(
            (listOfMaps) {
              return listOfMaps.map((playerMap) {
                return GamePlayerModel.fromJson(playerMap);
              }).toList();
            },
          );
    } catch (e) {
      throw ServerException(
          'Errore nello streaming dei giocatori: ${_extractErrorMessage(e)}');
    }
  }

  // ------------------ UPDATE GAME PLAYER ------------------ //
  @override
  Future<GamePlayerModel> updateGamePlayer({
    required String playerId,
    required String sessionId,
    required String userId,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft,
  }) async {
    return _tryDatabaseOperation(() async {
      final Map<String, dynamic> updates = {};
      if (score != null) updates['score'] = score;
      if (isGhost != null) updates['is_ghost'] = isGhost;
      if (hasUsedSpecialAbility != null) {
        updates['has_used_special_ability'] = hasUsedSpecialAbility;
      }
      if (hasUsedGhostProtocol != null) {
        updates['has_used_ghost_protocol'] = hasUsedGhostProtocol;
      }
      if (changeCategoryUsesLeft != null) {
        updates['change_category_uses_left'] = changeCategoryUsesLeft;
      }

      if (updates.isEmpty) {
        final currentPlayer = await supabaseClient
            .from('game_players')
            .select('*, profiles(name)')
            .eq('id', playerId)
            .single();

        return GamePlayerModel.fromJson(currentPlayer);
      }

      final response = await supabaseClient
          .from('game_players')
          .update(updates)
          .eq('id', playerId)
          .select('*, profiles(name)')
          .single();

      return GamePlayerModel.fromJson(response);
    });
  }

  // =====================================================================
  // GAME STATE MANAGEMENT
  // =====================================================================

  // ------------------ UPDATE GAME PLAYER NAME IN LOBBY ------------------ //
  @override
  Future<void> updateGamePlayerNameInLobbyDb({
    required String playerId,
    required String newName,
  }) async {
    return _tryDatabaseOperation(() async {
      // Assuming 'game_players' table has a 'name' column for the display name in lobby
      await supabaseClient
          .from('game_players')
          .update({'name': newName}).eq('id', playerId);
    });
  }

  // ------------------ REMOVE GAME PLAYER FROM LOBBY ------------------ //
  @override
  Future<void> removeGamePlayerFromLobbyDb({
    required String playerId,
    required String sessionId,
  }) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient
          .from('game_players')
          .delete()
          .match({'id': playerId, 'session_id': sessionId});
    });
  }

  // ------------------ UPDATE GAME STATE ------------------ //
  @override
  Future<GameSessionModel> updateGameState({
    required String sessionId,
    Map<String, dynamic>? newGameState,
    String? currentTurnUserId,
    String? status,
  }) async {
    return _tryDatabaseOperation(() async {
      final Map<String, dynamic> updates = {};

      if (newGameState != null) {
        updates['game_state'] = newGameState;
      }
      if (currentTurnUserId != null) {
        updates['current_turn_user_id'] = currentTurnUserId;
      }
      if (status != null) {
        updates['status'] = status;
      }

      final response = await supabaseClient
          .from('game_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select()
          .single();

      return GameSessionModel.fromJson(response);
    });
  }
}
