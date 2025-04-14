part of 'app_league_cubit.dart';

sealed class AppLeagueState extends Equatable {
  const AppLeagueState();

  @override
  List<Object> get props => [];
}

final class AppLeagueInitial extends AppLeagueState {}

final class AppLeagueExists extends AppLeagueState {
  final List<League> leagues;

  const AppLeagueExists({required this.leagues});

  @override
  List<Object> get props => [leagues];
}
