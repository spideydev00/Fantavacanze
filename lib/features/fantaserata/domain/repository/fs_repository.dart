import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

abstract interface class FsRepository {
  Future<Either<Failure, FsLeague>> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  });

  Future<Either<Failure, FsLeague>> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<Either<Failure, FsLeague>> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  });

  Future<Either<Failure, FsLeague>> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<Either<Failure, FsLeague>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  });

  Future<Either<Failure, FsLeague>> deleteMemory({
    required String leagueId,
    required String memoryId,
  });

  Future<Either<Failure, FsLeague>> removeParticipant({
    required String leagueId,
    required String participantId,
  });

  Future<Either<Failure, void>> exitLeague({
    required String leagueId,
    required String userId,
  });

  Future<Either<Failure, void>> deleteLeague({
    required String leagueId,
  });

  Future<Either<Failure, FsLeague?>> getFsLeague();
}
