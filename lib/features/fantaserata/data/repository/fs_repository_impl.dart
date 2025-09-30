import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_remote_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/local/fs_local_data_source.dart';

class FsRepositoryImpl implements FsRepository {
  final FsRemoteDataSource remoteDataSource;
  final FsLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  const FsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, FsLeague>> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.createLeague(
        name: name,
        description: description,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      await localDataSource.cacheFsLeague(league);

      return right(league);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsLeague>> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        userId: userId,
        userName: userName,
      );

      await localDataSource.cacheFsLeague(league);

      return right(league);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsLeague>> removeParticipant({
    required String leagueId,
    required String participantId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.removeParticipant(
        leagueId: leagueId,
        participantId: participantId,
      );

      await localDataSource.cacheFsLeague(league);

      return right(league);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.exitLeague(
        leagueId: leagueId,
        userId: userId,
      );

      await localDataSource.clearFsLeagueCache();

      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeague({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.deleteLeague(leagueId: leagueId);

      await localDataSource.clearFsLeagueCache();

      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsLeague?>> getFsLeague() async {
    try {
      // If connected, fetch fresh data
      if (!await connectionChecker.isConnected) {
        // If not connected, return cached data if available
        final cachedLeague = await localDataSource.getCachedFsLeague();

        if (cachedLeague != null) {
          return right(cachedLeague);
        } else {
          return left(const Failure(
              'Nessuna connessione internet e nessuna lega in cache'));
        }
      }

      final remoteLeague = await remoteDataSource.getFsLeague();

      if (remoteLeague != null) {
        await localDataSource.cacheFsLeague(remoteLeague);
        return right(remoteLeague);
      } else {
        return right(null);
      }
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsLeague>> uploadWinnerPhoto({
    required String leagueId,
    required Uint8List imageBytes,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.uploadWinnerPhoto(
        leagueId: leagueId,
        imageBytes: imageBytes,
      );

      await localDataSource.cacheFsLeague(league);

      return right(league);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FsLeague>> deleteWinnerPhoto({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league =
          await remoteDataSource.deleteWinnerPhoto(leagueId: leagueId);

      await localDataSource.cacheFsLeague(league);

      return right(league);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearFsLeagueCache() async {
    try {
      await localDataSource.clearFsLeagueCache();

      return right(null);
    } on CacheException catch (e) {
      return left(Failure(e.message));
    }
  }
}
