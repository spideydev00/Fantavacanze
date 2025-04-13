import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/features/league/data/remote_data_source/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;

  LeagueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  }) async {
    try {
      final league = await remoteDataSource.createLeague(
        name: name,
        description: description ?? "",
        isTeamBased: isTeamBased,
        admins: admins,
        rules: rules,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> getLeague(String leagueId) async {
    try {
      final league = await remoteDataSource.getLeague(leagueId);
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getUserLeagues() async {
    try {
      final leagues = await remoteDataSource.getUserLeagues();
      return Right(leagues);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      final league = await remoteDataSource.updateLeague(
        leagueId: leagueId,
        name: name,
        description: description,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeague(String leagueId) async {
    try {
      await remoteDataSource.deleteLeague(leagueId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        userId: userId,
        teamName: teamName,
        teamMembers: teamMembers,
        specificLeagueId: specificLeagueId,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message, data: e.data));
    }
  }

  @override
  Future<Either<Failure, League>> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    try {
      final league = await remoteDataSource.exitLeague(
        leagueId: leagueId,
        userId: userId,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  }) async {
    try {
      final league = await remoteDataSource.updateTeamName(
        leagueId: leagueId,
        userId: userId,
        newName: newName,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String userId,
    String? description,
  }) async {
    try {
      final league = await remoteDataSource.addEvent(
        leagueId: leagueId,
        name: name,
        points: points,
        userId: userId,
        description: description,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    try {
      final league = await remoteDataSource.removeEvent(
        leagueId: leagueId,
        eventId: eventId,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  }) async {
    try {
      final league = await remoteDataSource.addMemory(
        leagueId: leagueId,
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        relatedEventId: relatedEventId,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> removeMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    try {
      final league = await remoteDataSource.removeMemory(
        leagueId: leagueId,
        memoryId: memoryId,
      );
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Rule>>> getRules(String mode) async {
    try {
      final rules = await remoteDataSource.getRules(mode: mode);
      return Right(rules);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
