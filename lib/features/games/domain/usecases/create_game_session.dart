import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class CreateGameSession
    implements Usecase<GameSession, CreateGameSessionParams> {
  final GameRepository gameRepository;

  CreateGameSession(this.gameRepository);

  @override
  Future<Either<Failure, GameSession>> call(
      CreateGameSessionParams params) async {
    return await gameRepository.createGameSession(
      adminId: params.adminId,
      gameType: params.gameType,
      userName: params.userName,
    );
  }
}

class CreateGameSessionParams {
  final String adminId;
  final GameType gameType;
  final String userName;

  CreateGameSessionParams({
    required this.adminId,
    required this.gameType,
    required this.userName,
  });
}
