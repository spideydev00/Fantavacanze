import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class UpdateGamePlayerNameInLobby
    implements Usecase<void, UpdateGamePlayerNameInLobbyParams> {
  final GameRepository gameRepository;

  UpdateGamePlayerNameInLobby(this.gameRepository);

  @override
  Future<Either<Failure, void>> call(
      UpdateGamePlayerNameInLobbyParams params) async {
    return await gameRepository.updateGamePlayerNameInLobby(
      playerId: params.playerId,
      newName: params.newName,
      sessionId: params.sessionId,
    );
  }
}

class UpdateGamePlayerNameInLobbyParams {
  final String playerId;
  final String newName;
  final String sessionId;

  UpdateGamePlayerNameInLobbyParams({
    required this.playerId,
    required this.newName,
    required this.sessionId,
  });
}
