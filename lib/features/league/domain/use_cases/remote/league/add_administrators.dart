import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddAdministratorsParams {
  final League league;
  final List<String> userIds;

  AddAdministratorsParams({
    required this.league,
    required this.userIds,
  });
}

class AddAdministrators implements Usecase<League, AddAdministratorsParams> {
  final LeagueRepository leagueRepository;

  AddAdministrators({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(AddAdministratorsParams params) async {
    return leagueRepository.addAdministrators(
      league: params.league,
      userIds: params.userIds,
    );
  }
}
