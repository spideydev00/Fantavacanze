import 'dart:io';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UploadImage implements Usecase<String, UploadImageParams> {
  final LeagueRepository leagueRepository;

  UploadImage({required this.leagueRepository});

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) async {
    return leagueRepository.uploadImage(
      leagueId: params.leagueId,
      imageFile: params.imageFile,
    );
  }
}

@immutable
class UploadImageParams {
  final String leagueId;
  final File imageFile;

  const UploadImageParams({
    required this.leagueId,
    required this.imageFile,
  });
}
