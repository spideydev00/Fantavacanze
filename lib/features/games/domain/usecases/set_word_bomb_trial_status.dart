import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/word_bomb_repository.dart';

class SetWordBombTrialStatusParams {
  final bool isActive;
  final String userId;

  SetWordBombTrialStatusParams({required this.isActive, required this.userId});
}

class SetWordBombTrialStatus
    implements Usecase<bool, SetWordBombTrialStatusParams> {
  final WordBombRepository repository;

  SetWordBombTrialStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetWordBombTrialStatusParams params) {
    return repository.setWordBombTrialStatus(
      isActive: params.isActive,
      userId: params.userId,
    );
  }
}
