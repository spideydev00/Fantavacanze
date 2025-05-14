import 'dart:io';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UploadTeamLogo implements Usecase<String, UploadTeamLogoParams> {
  final LeagueRepository leagueRepository;

  UploadTeamLogo({required this.leagueRepository});

  @override
  Future<Either<Failure, String>> call(UploadTeamLogoParams params) async {
    return leagueRepository.uploadTeamLogo(
      leagueId: params.leagueId,
      teamName: params.teamName,
      imageFile: params.imageFile,
    );
  }
}

@immutable
class UploadTeamLogoParams {
  final String leagueId;
  final String teamName;
  final File imageFile;

  const UploadTeamLogoParams({
    required this.leagueId,
    required this.teamName,
    required this.imageFile,
  });
}
