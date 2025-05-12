import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class DeleteNote implements Usecase<void, DeleteNoteParams> {
  final LeagueRepository leagueRepository;

  DeleteNote({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return leagueRepository.deleteNote(params.leagueId, params.noteId);
  }
}

@immutable
class DeleteNoteParams {
  final String leagueId;
  final String noteId;

  const DeleteNoteParams({
    required this.leagueId,
    required this.noteId,
  });
}
