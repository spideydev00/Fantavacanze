import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class UpdateGamePlayer implements Usecase<GamePlayer, UpdateGamePlayerParams> {
  final GameRepository gameRepository;

  UpdateGamePlayer(this.gameRepository);

  @override
  Future<Either<Failure, GamePlayer>> call(
      UpdateGamePlayerParams params) async {
    return await gameRepository.updateGamePlayer(
      playerId: params.playerId,
      sessionId: params.sessionId,
      userId: params.userId,
      score: params.score,
      isGhost: params.isGhost,
      hasUsedSpecialAbility: params.hasUsedSpecialAbility,
      hasUsedGhostProtocol: params.hasUsedGhostProtocol,
      changeCategoryUsesLeft: params.changeCategoryUsesLeft,
    );
  }
}

class UpdateGamePlayerParams {
  final String playerId;
  final String sessionId;
  final String userId;
  final int? score;
  final bool? isGhost;
  final bool? hasUsedSpecialAbility;
  final bool? hasUsedGhostProtocol;
  final int? changeCategoryUsesLeft;

  UpdateGamePlayerParams({
    required this.playerId,
    required this.sessionId,
    required this.userId,
    this.score,
    this.isGhost,
    this.hasUsedSpecialAbility,
    this.hasUsedGhostProtocol,
    this.changeCategoryUsesLeft,
  });
}
