import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';

abstract interface class FsDynamicRulesRepository {
  Future<Either<Failure, FsRule>> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, FsRule>> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, FsRule>> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<Either<Failure, List<FsRule>>> getUserDynamicRules({
    required String userId,
    required String leagueId,
  });
}
