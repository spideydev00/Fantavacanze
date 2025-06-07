import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';

abstract interface class GameRepository {
  Future<Either<Failure, GameSession>> createGameSession({
    required String adminId,
    required GameType gameType,
  });

  Future<Either<Failure, GameSession>> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
    String? userAvatarUrl,
  });

  Future<Either<Failure, void>> leaveGameSession({
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
    required Map<String, dynamic> newGameState,
    String? currentTurnUserId,
    String? status, // GameStatus as string
  });

  Future<Either<Failure, GamePlayer>> updateGamePlayer({
    required String playerId, // This is GamePlayer's own ID
    required String sessionId, // session_id for targeting the right player
    required String userId, // user_id for targeting the right player
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
  });
}
