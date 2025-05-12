import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotes implements Usecase<List<NoteModel>, String> {
  final LeagueRepository leagueRepository;

  GetNotes({required this.leagueRepository});

  @override
  Future<Either<Failure, List<NoteModel>>> call(String leagueId) async {
    return leagueRepository.getNotes(leagueId);
  }
}
