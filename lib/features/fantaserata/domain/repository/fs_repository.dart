import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
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

  Future<Either<Failure, FsLeague>> uploadWinnerPhoto({
    required String leagueId,
    required Uint8List imageBytes,
  });

  Future<Either<Failure, FsLeague>> deleteWinnerPhoto({
    required String leagueId,
  });

  Future<Either<Failure, void>> clearFsLeagueCache();
}
