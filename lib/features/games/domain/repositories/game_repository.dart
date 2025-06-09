import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';

abstract interface class GameRepository {
  Future<Either<Failure, GameSession>> createGameSession(
      {required String adminId,
      required GameType gameType,
      required String userName});

  Future<Either<Failure, GameSession>> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<Either<Failure, bool>> leaveGameSession({
    // Return type changed
    required String sessionId,
    required String userId,
  });

  Stream<Either<Failure, GameSession>> streamGameSession({
    required String sessionId,
  });

  Stream<Either<Failure, List<GamePlayer>>> streamLobbyPlayers({
    required String sessionId,
  });

  Future<Either<Failure, GameSession>> updateGameState({
    required String sessionId,
    Map<String, dynamic>? newGameState,
    String? currentTurnUserId,
    String? status,
  });

  Future<Either<Failure, GamePlayer>> updateGamePlayer({
    required String playerId,
    required String sessionId,
    required String userId,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft,
  });

  Future<Either<Failure, void>> updateGamePlayerNameInLobby({
    required String playerId,
    required String newName,
    required String
        sessionId, // Added sessionId for context if needed by backend/rules
  });

  Future<Either<Failure, void>> removeGamePlayerFromLobby({
    required String playerId,
    required String sessionId,
  });

  Future<Either<Failure, void>> killSession({required String sessionId});
}
