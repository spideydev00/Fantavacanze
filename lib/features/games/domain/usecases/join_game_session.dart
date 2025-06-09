import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class JoinGameSession implements Usecase<GameSession, JoinGameSessionParams> {
  final GameRepository gameRepository;

  JoinGameSession(this.gameRepository);

  @override
  Future<Either<Failure, GameSession>> call(
      JoinGameSessionParams params) async {
    return await gameRepository.joinGameSession(
      inviteCode: params.inviteCode,
      userId: params.userId,
      userName: params.userName,
    );
  }
}

class JoinGameSessionParams {
  final String inviteCode;
  final String userId;
  final String userName;

  JoinGameSessionParams({
    required this.inviteCode,
    required this.userId,
    required this.userName,
  });
}
