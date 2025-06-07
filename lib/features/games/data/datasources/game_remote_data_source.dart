import 'dart:math';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/game_player_model.dart';
import 'package:fantavacanze_official/features/games/data/models/game_session_model.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class GameRemoteDataSource {
  Future<GameSessionModel> createGameSession({
    required String adminId,
    required GameType gameType,
  });

  Future<GameSessionModel> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
    String? userAvatarUrl,
  });

  Future<void> leaveGameSession({
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
    required Map<String, dynamic> newGameState,
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
  });
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final SupabaseClient supabaseClient;

  GameRemoteDataSourceImpl({required this.supabaseClient});

  String _generateInviteCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Future<GameSessionModel> createGameSession({
    required String adminId,
    required GameType gameType,
  }) async {
    try {
      final inviteCode = _generateInviteCode(6);
      final response = await supabaseClient
          .from('game_sessions')
          .insert({
            'admin_id': adminId,
            'game_type': gameTypeToString(gameType),
            'invite_code': inviteCode,
            'status': 'waiting', // Default status
          })
          .select()
          .single();

      final gameSession = GameSessionModel.fromJson(response);

      // Automatically add admin as a player
      await supabaseClient.from('profiles').select().eq('id', adminId).single();

      // final adminUser = UserModel.fromJson(adminProfile);

      await supabaseClient.from('game_players').insert({
        'session_id': gameSession.id,
        'user_id': adminId,
        'score': 0,
        // 'user_name': adminUser.name, // Not needed if joining profiles table on read
        // 'user_avatar_url': adminUser.avatarUrl, // Not needed
      });

      return gameSession;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GameSessionModel> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
    String? userAvatarUrl,
  }) async {
    try {
      final sessionResponse = await supabaseClient
          .from('game_sessions')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      final gameSession = GameSessionModel.fromJson(sessionResponse);

      if (gameSession.status != GameStatus.waiting) {
        throw ServerException(
            'Impossibile unirsi, la partita è già iniziata o conclusa.');
      }

      // Check if player already exists
      final existingPlayer = await supabaseClient
          .from('game_players')
          .select()
          .eq('session_id', gameSession.id)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingPlayer == null) {
        await supabaseClient.from('game_players').insert({
          'session_id': gameSession.id,
          'user_id': userId,
          'score': 0,
          // 'user_name': userName, // Not needed if joining profiles table on read
          // 'user_avatar_url': userAvatarUrl, // Not needed
        });
      }
      return gameSession;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows found
        throw ServerException('Codice invito non valido.');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveGameSession(
      {required String sessionId, required String userId}) async {
    try {
      await supabaseClient
          .from('game_players')
          .delete()
          .match({'session_id': sessionId, 'user_id': userId});

      // Optional: If admin leaves, handle session (e.g., assign new admin or end session)
      // This logic might be better suited in a use case or BLoC after checking if user is admin.
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<GameSessionModel> streamGameSession({required String sessionId}) {
    try {
      return supabaseClient
          .from('game_sessions')
          .stream(primaryKey: ['id'])
          .eq('id', sessionId)
          .map((maps) {
            if (maps.isEmpty) {
              throw ServerException('Sessione non trovata o accesso negato.');
            }
            return GameSessionModel.fromJson(maps.first);
          });
    } catch (e) {
      // This catch might not be effective for stream errors in the same way.
      // Stream errors are typically handled by the listener.
      // Consider wrapping the stream subscription in the repository/use case with error handling.
      throw ServerException(
          'Errore nello streaming della sessione: ${e.toString()}');
    }
  }

  @override
  Stream<List<GamePlayerModel>> streamLobbyPlayers(
      {required String sessionId}) {
    try {
      return supabaseClient
          .from('game_players')
          .stream(primaryKey: ['id'])
          .eq('session_id', sessionId)
          .map((listOfMaps) {
            // Each playerMap here will be from the 'game_players' table directly.
            // GamePlayerModel.fromJson needs to handle this.
            // If 'userName' and 'userAvatarUrl' were solely dependent on the 'profiles' join,
            // they might be null or default here.
            return listOfMaps
                .map((playerMap) => GamePlayerModel.fromJson(playerMap))
                .toList();
          });
    } catch (e) {
      throw ServerException(
          'Errore nello streaming dei giocatori: ${e.toString()}');
    }
  }

  @override
  Future<GameSessionModel> updateGameState({
    required String sessionId,
    required Map<String, dynamic> newGameState,
    String? currentTurnUserId,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> updates = {'game_state': newGameState};
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
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GamePlayerModel> updateGamePlayer({
    required String playerId, // This is the primary key of game_players table
    required String
        sessionId, // Used for matching, though playerId should be unique
    required String userId, // Used for matching
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (score != null) updates['score'] = score;
      if (isGhost != null) updates['is_ghost'] = isGhost;
      if (hasUsedSpecialAbility != null) {
        updates['has_used_special_ability'] = hasUsedSpecialAbility;
      }

      if (updates.isEmpty) {
        // If nothing to update, fetch and return current state
        final currentPlayer = await supabaseClient
            .from('game_players')
            .select('*, profiles(name, avatar_url)')
            .eq('id', playerId) // Use the direct ID of the game_players record
            .single();
        return GamePlayerModel.fromJson(currentPlayer);
      }

      final response = await supabaseClient
          .from('game_players')
          .update(updates)
          .eq('id', playerId) // Use the direct ID of the game_players record
          .select(
              '*, profiles(name, avatar_url)') // Fetch with profile data after update
          .single();
      return GamePlayerModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
