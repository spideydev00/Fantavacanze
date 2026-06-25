part of 'partner_cubit.dart';

sealed class PartnerState extends Equatable {
  const PartnerState();

  @override
  List<Object?> get props => [];
}

final class PartnerInitial extends PartnerState {
  const PartnerInitial();
}

final class PartnerLoading extends PartnerState {
  const PartnerLoading();
}

final class PartnerFailure extends PartnerState {
  final String message;

  const PartnerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class PartnerDestinationsLoaded extends PartnerState {
  final PartnerCatalog catalog;

  const PartnerDestinationsLoaded(this.catalog);

  @override
  List<Object?> get props => [catalog];
}

final class PartnerSearchLoaded extends PartnerState {
  final PartnerSearchResult result;

  const PartnerSearchLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

final class PartnerLeagueReady extends PartnerState {
  final League league;

  const PartnerLeagueReady(this.league);

  @override
  List<Object?> get props => [league];
}

final class PartnerRankingLoaded extends PartnerState {
  final List<GeneralRankingEntry> ranking;

  const PartnerRankingLoaded(this.ranking);

  @override
  List<Object?> get props => [ranking];
}
