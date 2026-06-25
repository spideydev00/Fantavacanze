import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/create_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_destinations.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_general_ranking.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/join_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/search_partner_league.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'partner_state.dart';

class PartnerCubit extends Cubit<PartnerState> {
  final GetPartnerDestinations _getPartnerDestinations;
  final CreatePartnerLeague _createPartnerLeague;
  final SearchPartnerLeague _searchPartnerLeague;
  final JoinPartnerLeague _joinPartnerLeague;
  final GetPartnerGeneralRanking _getPartnerGeneralRanking;
  final AppLeagueCubit _appLeagueCubit;

  PartnerCubit({
    required GetPartnerDestinations getPartnerDestinations,
    required CreatePartnerLeague createPartnerLeague,
    required SearchPartnerLeague searchPartnerLeague,
    required JoinPartnerLeague joinPartnerLeague,
    required GetPartnerGeneralRanking getPartnerGeneralRanking,
    required AppLeagueCubit appLeagueCubit,
  })  : _getPartnerDestinations = getPartnerDestinations,
        _createPartnerLeague = createPartnerLeague,
        _searchPartnerLeague = searchPartnerLeague,
        _joinPartnerLeague = joinPartnerLeague,
        _getPartnerGeneralRanking = getPartnerGeneralRanking,
        _appLeagueCubit = appLeagueCubit,
        super(const PartnerInitial());

  Future<void> loadDestinations(String partnerSlug) async {
    emit(const PartnerLoading());
    final result = await _getPartnerDestinations(
      GetPartnerDestinationsParams(partnerSlug: partnerSlug),
    );
    result.fold(
      (failure) => emit(PartnerFailure(failure.message)),
      (catalog) => emit(PartnerDestinationsLoaded(catalog)),
    );
  }

  Future<void> createLeague({
    required String userName,
    required String destinationId,
    required String name,
    required String password,
    String? description,
  }) async {
    emit(const PartnerLoading());
    final result = await _createPartnerLeague(
      CreatePartnerLeagueParams(
        userName: userName,
        destinationId: destinationId,
        name: name,
        password: password,
        description: description,
      ),
    );
    await result.fold(
      (failure) async => emit(PartnerFailure(failure.message)),
      (league) async {
        await _appLeagueCubit.getUserLeagues();
        emit(PartnerLeagueReady(league));
      },
    );
  }

  Future<void> searchLeague({
    required String inviteCode,
    required String password,
  }) async {
    emit(const PartnerLoading());
    final result = await _searchPartnerLeague(
      SearchPartnerLeagueParams(inviteCode: inviteCode, password: password),
    );
    result.fold(
      (failure) => emit(PartnerFailure(failure.message)),
      (searchResult) => emit(PartnerSearchLoaded(searchResult)),
    );
  }

  Future<void> joinLeague({
    required String userName,
    required String inviteCode,
    required String password,
  }) async {
    emit(const PartnerLoading());
    final result = await _joinPartnerLeague(
      JoinPartnerLeagueParams(
        userName: userName,
        inviteCode: inviteCode,
        password: password,
      ),
    );
    await result.fold(
      (failure) async => emit(PartnerFailure(failure.message)),
      (league) async {
        await _appLeagueCubit.getUserLeagues();
        emit(PartnerLeagueReady(league));
      },
    );
  }

  Future<void> loadGeneralRanking(String leagueId) async {
    emit(const PartnerLoading());
    final result = await _getPartnerGeneralRanking(
      GetPartnerGeneralRankingParams(leagueId: leagueId),
    );
    result.fold(
      (failure) => emit(PartnerFailure(failure.message)),
      (ranking) => emit(PartnerRankingLoaded(ranking)),
    );
  }

  void reset() {
    emit(const PartnerInitial());
  }
}
