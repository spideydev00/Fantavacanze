import 'dart:io';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UploadMedia implements Usecase<String, UploadMediaParams> {
  final LeagueRepository leagueRepository;

  UploadMedia({required this.leagueRepository});

  @override
  Future<Either<Failure, String>> call(UploadMediaParams params) async {
    return leagueRepository.uploadMedia(
      leagueId: params.leagueId,
      mediaFile: params.mediaFile,
    );
  }
}

@immutable
class UploadMediaParams {
  final String leagueId;
  final File mediaFile;

  const UploadMediaParams({
    required this.leagueId,
    required this.mediaFile,
  });
}
