import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class RefreshFsRule implements Usecase<void, RefreshFsRuleParams> {
  final FsRepository fsRepository;

  const RefreshFsRule(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(RefreshFsRuleParams params) async {
    return await fsRepository.refreshRule(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class RefreshFsRuleParams {
  final String userId;
  final String leagueId;
  final String challengeId;

  const RefreshFsRuleParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}
