import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class StreamGameSession implements StreamUsecase<GameSession, String> {
  final GameRepository gameRepository;

  StreamGameSession(this.gameRepository);

  @override
  Stream<Either<Failure, GameSession>> call(String sessionId) {
    return gameRepository.streamGameSession(sessionId: sessionId);
  }
}
