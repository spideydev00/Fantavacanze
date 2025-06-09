import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class UpdateGameState implements Usecase<GameSession, UpdateGameStateParams> {
  final GameRepository gameRepository;

  UpdateGameState(this.gameRepository);

  @override
  Future<Either<Failure, GameSession>> call(
      UpdateGameStateParams params) async {
    return await gameRepository.updateGameState(
      sessionId: params.sessionId,
      newGameState: params.newGameState,
      currentTurnUserId: params.currentTurnUserId,
      status: params.status != null ? gameStatusToString(params.status!) : null,
    );
  }
}

class UpdateGameStateParams {
  final String sessionId;
  final Map<String, dynamic>? newGameState;
  final String? currentTurnUserId;
  final GameStatus? status;

  UpdateGameStateParams({
    required this.sessionId,
    this.newGameState,
    this.currentTurnUserId,
    this.status,
  });
}
