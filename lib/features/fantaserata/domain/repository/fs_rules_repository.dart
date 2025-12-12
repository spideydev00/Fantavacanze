import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule_completion.dart';

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

  Future<Either<Failure, Map<String, dynamic>>> setRuleAsCompleted({
    required FsRule rule,
  });

  Future<Either<Failure, FsRule>> setRuleAsUncompleted({
    required FsRule rule,
    String? completionId, // Unique completion ID for targeted deletion
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

  Future<Either<Failure, List<FsRuleCompletion>>> getRuleCompletions({
    required String leagueId,
  });
}
