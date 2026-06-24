import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class GetPartnerDestinations implements Usecase<PartnerCatalog, GetPartnerDestinationsParams> {
  final LeagueRepository leagueRepository;

  GetPartnerDestinations({required this.leagueRepository});

  @override
  Future<Either<Failure, PartnerCatalog>> call(GetPartnerDestinationsParams params) async {
    return leagueRepository.getPartnerDestinations(params.partnerSlug);
  }
}

@immutable
class GetPartnerDestinationsParams {
  final String partnerSlug;

  const GetPartnerDestinationsParams({required this.partnerSlug});
}
