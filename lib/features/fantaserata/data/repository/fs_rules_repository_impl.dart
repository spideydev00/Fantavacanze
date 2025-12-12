import 'package:fantavacanze_official/features/fantaserata/data/models/rule/fs_rule_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule_completion.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_rules_remote_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/local/fs_rules_local_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule_completion/fs_rule_completion_model.dart';

class FsRulesRepositoryImpl implements FsRulesRepository {
  final FsRulesRemoteDataSource remoteDataSource;
  final FsRulesLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  const FsRulesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, FsRule>> refreshRule({
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rule = await remoteDataSource.refreshRule(
        leagueId: leagueId,
        challengeId: challengeId,
      );

      await localDataSource.updateSingleRule(leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsRule>> unlockRule({
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rule = await remoteDataSource.unlockRule(
        leagueId: leagueId,
        challengeId: challengeId,
      );

      await localDataSource.updateSingleRule(leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsRule>> lockRule({
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rule = await remoteDataSource.lockRule(
        leagueId: leagueId,
        challengeId: challengeId,
      );

      await localDataSource.updateSingleRule(leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> setRuleAsCompleted({
    required FsRule rule,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final ruleModel =
          rule is FsRuleModel ? rule : FsRuleModel.fromEntity(rule);

      // Mark rule as completed
      final ruleAndCompletion = await remoteDataSource.setRuleAsCompleted(
        rule: ruleModel,
      );

      final fsRule = ruleAndCompletion['fsRule'] as FsRuleModel;
      final completion =
          ruleAndCompletion['completion'] as FsRuleCompletionModel;

      await localDataSource.updateSingleRule(
        rule.leagueId,
        fsRule,
      );

      return right({
        'fsRule': fsRule,
        'completion': completion,
      });
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsRule>> setRuleAsUncompleted({
    required FsRule rule,
    String? completionId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final ruleModel =
          rule is FsRuleModel ? rule : FsRuleModel.fromEntity(rule);

      // Mark rule as uncompleted
      final updatedRule = await remoteDataSource.setRuleAsUncompleted(
        rule: ruleModel,
        completionId: completionId,
      );

      await localDataSource.updateSingleRule(updatedRule.leagueId, updatedRule);

      return right(updatedRule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FsRule>>> getLeagueRules({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Try cache first
        try {
          final cachedRules = await localDataSource.getCachedRules(leagueId);
          return right(cachedRules);
        } catch (e) {
          return left(Failure('Nessuna connessione e nessun dato in cache'));
        }
      }

      final remoteRules = await remoteDataSource.getLeagueRules(
        leagueId: leagueId,
      );

      // Cache the fresh data
      await localDataSource.cacheRules(leagueId, remoteRules);

      return right(remoteRules);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FsRule>>> insertRulesForLeagueFromExisting({
    required String leagueId,
    required String name,
    required num points,
    required String typeText,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rules = await remoteDataSource.insertRulesForLeagueFromExisting(
        leagueId: leagueId,
        name: name,
        points: points,
        typeText: typeText,
      );

      // Update cache with new rules
      await localDataSource.cacheRules(leagueId, rules);

      return right(rules);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FsRuleCompletion>>> getRuleCompletions({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final completions =
          await remoteDataSource.getRuleCompletions(leagueId: leagueId);

      return right(completions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
