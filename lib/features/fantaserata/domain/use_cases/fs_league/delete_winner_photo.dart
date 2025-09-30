import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class DeleteWinnerPhoto implements Usecase<FsLeague, DeleteWinnerPhotoParams> {
  final FsRepository repository;

  const DeleteWinnerPhoto(this.repository);

  @override
  Future<Either<Failure, FsLeague>> call(DeleteWinnerPhotoParams params) async {
    return await repository.deleteWinnerPhoto(
      leagueId: params.leagueId,
    );
  }
}

class DeleteWinnerPhotoParams {
  final String leagueId;

  const DeleteWinnerPhotoParams({
    required this.leagueId,
  });
}
