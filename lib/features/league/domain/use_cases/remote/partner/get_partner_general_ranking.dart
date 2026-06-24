import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class GetPartnerGeneralRanking implements Usecase<List<GeneralRankingEntry>, GetPartnerGeneralRankingParams> {
  final LeagueRepository leagueRepository;

  GetPartnerGeneralRanking({required this.leagueRepository});

  @override
  Future<Either<Failure, List<GeneralRankingEntry>>> call(GetPartnerGeneralRankingParams params) async {
    return leagueRepository.getPartnerGeneralRanking(params.leagueId);
  }
}

@immutable
class GetPartnerGeneralRankingParams {
  final String leagueId;

  const GetPartnerGeneralRankingParams({required this.leagueId});
}
