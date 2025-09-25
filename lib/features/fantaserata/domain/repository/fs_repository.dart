import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_event.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';

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

  Future<Either<Failure, FsEvent>> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  });

  Future<Either<Failure, void>> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<Either<Failure, FsMemory>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  });

  Future<Either<Failure, void>> deleteMemory({
    required String leagueId,
    required String memoryId,
  });

  Future<Either<Failure, void>> removeParticipant({
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

  Future<Either<Failure, void>> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, void>> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<Either<Failure, void>> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<Either<Failure, List<FsLeague>>> getFsLeagues();
}
