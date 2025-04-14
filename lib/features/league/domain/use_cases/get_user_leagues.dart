import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserLeagues implements Usecase<List<League>, NoParams> {
  final LeagueRepository leagueRepository;

  GetUserLeagues({required this.leagueRepository});

  @override
  Future<Either<Failure, List<League>>> call(NoParams params) async {
    return leagueRepository.getUserLeagues();
  }
}
