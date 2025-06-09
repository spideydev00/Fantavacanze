import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class RemoveGamePlayerFromLobby
    implements Usecase<void, RemoveGamePlayerFromLobbyParams> {
  final GameRepository gameRepository;

  RemoveGamePlayerFromLobby(this.gameRepository);

  @override
  Future<Either<Failure, void>> call(
      RemoveGamePlayerFromLobbyParams params) async {
    return await gameRepository.removeGamePlayerFromLobby(
      playerId: params.playerId,
      sessionId: params.sessionId,
    );
  }
}

class RemoveGamePlayerFromLobbyParams {
  final String playerId;
  final String sessionId;

  RemoveGamePlayerFromLobbyParams({
    required this.playerId,
    required this.sessionId,
  });
}
