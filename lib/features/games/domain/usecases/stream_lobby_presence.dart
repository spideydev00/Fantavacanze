import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';
import 'package:fpdart/fpdart.dart';

class StreamLobbyPresence implements StreamUsecase<Set<String>, String> {
  StreamLobbyPresence(this.gameRepository);

  final GameRepository gameRepository;

  @override
  Stream<Either<Failure, Set<String>>> call(String sessionId) {
    return gameRepository.streamLobbyPresence(sessionId: sessionId);
  }
}
