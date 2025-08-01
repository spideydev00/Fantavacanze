import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotes implements Usecase<List<Note>, String> {
  final LeagueRepository leagueRepository;

  GetNotes({required this.leagueRepository});

  @override
  Future<Either<Failure, List<Note>>> call(String leagueId) async {
    return leagueRepository.getNotes(leagueId);
  }
}
