import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class UnlockFsRule implements Usecase<void, UnlockFsRuleParams> {
  final FsRepository fsRepository;

  const UnlockFsRule(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(UnlockFsRuleParams params) async {
    return await fsRepository.unlockRule(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class UnlockFsRuleParams {
  final String userId;
  final String leagueId;
  final String challengeId;

  const UnlockFsRuleParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}
