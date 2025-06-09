import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class LeaveGameSessionParams {
  final String sessionId;
  final String userId;

  LeaveGameSessionParams({required this.sessionId, required this.userId});
}

class LeaveGameSession implements Usecase<bool, LeaveGameSessionParams> {
  final GameRepository gameRepository;

  LeaveGameSession(this.gameRepository);

  @override
  Future<Either<Failure, bool>> call(LeaveGameSessionParams params) async {
    return await gameRepository.leaveGameSession(
      sessionId: params.sessionId,
      userId: params.userId,
    );
  }
}
