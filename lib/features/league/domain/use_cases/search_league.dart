import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchLeagueParams extends Equatable {
  final String inviteCode;

  const SearchLeagueParams({required this.inviteCode});

  @override
  List<Object?> get props => [inviteCode];
}

class SearchLeague {
  final LeagueRepository leagueRepository;

  SearchLeague({required this.leagueRepository});

  Future<Either<Failure, List<League>>> call(SearchLeagueParams params) {
    return leagueRepository.searchLeague(inviteCode: params.inviteCode);
  }
}
