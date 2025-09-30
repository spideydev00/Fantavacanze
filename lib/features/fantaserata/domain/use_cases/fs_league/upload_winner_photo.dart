import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class UploadWinnerPhoto implements Usecase<FsLeague, UploadWinnerPhotoParams> {
  final FsRepository repository;

  const UploadWinnerPhoto(this.repository);

  @override
  Future<Either<Failure, FsLeague>> call(UploadWinnerPhotoParams params) async {
    return await repository.uploadWinnerPhoto(
      leagueId: params.leagueId,
      imageBytes: params.imageBytes,
    );
  }
}

class UploadWinnerPhotoParams {
  final String leagueId;
  final Uint8List imageBytes;

  const UploadWinnerPhotoParams({
    required this.leagueId,
    required this.imageBytes,
  });
}
