import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class SaveNote implements Usecase<void, SaveNoteParams> {
  final LeagueRepository leagueRepository;

  SaveNote({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(SaveNoteParams params) async {
    return leagueRepository.saveNote(params.leagueId, params.note);
  }
}

@immutable
class SaveNoteParams {
  final String leagueId;
  final NoteModel note;

  const SaveNoteParams({
    required this.leagueId,
    required this.note,
  });
}
