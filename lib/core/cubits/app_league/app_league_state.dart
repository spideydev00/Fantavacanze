part of 'app_league_cubit.dart';

sealed class AppLeagueState extends Equatable {
  const AppLeagueState();

  @override
  List<Object?> get props => [];
}

final class AppLeagueInitial extends AppLeagueState {}

final class AppLeagueExists extends AppLeagueState {
  final List<League> leagues;
  final League selectedLeague;

  const AppLeagueExists({
    required this.leagues,
    required this.selectedLeague,
  });

  @override
  List<Object?> get props => [leagues, selectedLeague];

  // Helper method to create a new state with updated selected league
  AppLeagueExists copyWith({
    List<League>? leagues,
    League? selectedLeague,
  }) {
    return AppLeagueExists(
      leagues: leagues ?? this.leagues,
      selectedLeague: selectedLeague ?? this.selectedLeague,
    );
  }
}
