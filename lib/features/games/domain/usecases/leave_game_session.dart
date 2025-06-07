import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class LeaveGameSession implements Usecase<void, LeaveGameSessionParams> {
  final GameRepository gameRepository;

  LeaveGameSession(this.gameRepository);

  @override
  Future<Either<Failure, void>> call(LeaveGameSessionParams params) async {
    return await gameRepository.leaveGameSession(
      sessionId: params.sessionId,
      userId: params.userId,
    );
  }
}

class LeaveGameSessionParams {
  final String sessionId;
  final String userId;

  LeaveGameSessionParams({required this.sessionId, required this.userId});
}
