import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class KillGameSession implements Usecase<void, String> {
  final GameRepository gameRepository;

  KillGameSession(this.gameRepository);

  @override
  Future<Either<Failure, void>> call(String sessionId) async {
    return await gameRepository.killSession(sessionId: sessionId);
  }
}
