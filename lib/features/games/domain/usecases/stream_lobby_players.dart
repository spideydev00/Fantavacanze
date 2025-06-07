import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class StreamLobbyPlayers implements StreamUsecase<List<GamePlayer>, String> {
  final GameRepository gameRepository;

  StreamLobbyPlayers(this.gameRepository);

  @override
  Stream<Either<Failure, List<GamePlayer>>> call(String sessionId) {
    return gameRepository.streamLobbyPlayers(sessionId: sessionId);
  }
}
