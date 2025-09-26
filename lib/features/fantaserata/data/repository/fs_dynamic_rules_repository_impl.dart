import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_dynamic_rules_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_dynamic_rules_remote_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/local/fs_dynamic_rules_local_data_source.dart';

class FsDynamicRulesRepositoryImpl implements FsDynamicRulesRepository {
  final FsDynamicRulesRemoteDataSource remoteDataSource;
  final FsDynamicRulesLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  const FsDynamicRulesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, FsRule>> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rule = await remoteDataSource.refreshRule(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
      );

      await localDataSource.updateSingleRule(userId, leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsRule>> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final rule = await remoteDataSource.unlockRule(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
      );

      await localDataSource.updateSingleRule(userId, leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsRule>> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      // Mark rule as completed
      final rule = await remoteDataSource.setRuleAsCompleted(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
        ruleName: ruleName,
        points: points,
        type: type,
      );

      await localDataSource.updateSingleRule(userId, leagueId, rule);

      return right(rule);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FsRule>>> getUserDynamicRules({
    required String userId,
    required String leagueId,
  }) async {
    try {
      // If connected, fetch fresh data
      if (!await connectionChecker.isConnected) {
        // Try cache first
        try {
          final cachedRules =
              await localDataSource.getCachedDynamicRules(userId, leagueId);

          return right(cachedRules);
        } catch (e) {
          return left(Failure('Nessuna connessione e nessun dato in cache'));
        }
      }

      final remoteRules = await remoteDataSource.getUserDynamicRules(
        userId: userId,
        leagueId: leagueId,
      );

      // Cache the fresh data
      await localDataSource.cacheDynamicRules(userId, leagueId, remoteRules);

      return right(remoteRules);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } on CacheException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      // If everything fails, return empty list
      return right(<FsRule>[]);
    }
  }
}
