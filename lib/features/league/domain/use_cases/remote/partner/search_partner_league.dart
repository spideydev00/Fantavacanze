import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class SearchPartnerLeague implements Usecase<PartnerSearchResult, SearchPartnerLeagueParams> {
  final LeagueRepository leagueRepository;

  SearchPartnerLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, PartnerSearchResult>> call(SearchPartnerLeagueParams params) async {
    return leagueRepository.searchPartnerLeague(
      inviteCode: params.inviteCode,
      password: params.password,
    );
  }
}

@immutable
class SearchPartnerLeagueParams {
  final String inviteCode;
  final String password;

  const SearchPartnerLeagueParams({
    required this.inviteCode,
    required this.password,
  });
}
