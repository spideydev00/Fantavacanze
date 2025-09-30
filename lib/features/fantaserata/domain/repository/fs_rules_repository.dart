import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';

abstract interface class FsRulesRepository {
  Future<Either<Failure, FsRule>> refreshRule({
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, FsRule>> unlockRule({
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, FsRule>> lockRule({
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, FsRule>> setRuleAsCompleted({
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<Either<Failure, FsRule>> setRuleAsUncompleted({
    required String leagueId,
    required String userId,
    required String challengeId,
  });

  Future<Either<Failure, List<FsRule>>> getLeagueRules({
    required String leagueId,
  });

  Future<Either<Failure, List<FsRule>>> insertRulesForLeagueFromExisting({
    required String leagueId,
    required String name,
    required num points,
    required String typeText,
  });
}
