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
  final Map<String, MemberProfile> memberProfiles;

  const AppLeagueExists({
    required this.leagues,
    required this.selectedLeague,
    this.memberProfiles = const {},
  });

  @override
  List<Object?> get props => [
        leagues,
        selectedLeague,
        memberProfiles,
      ];

  AppLeagueExists copyWith({
    List<League>? leagues,
    League? selectedLeague,
    Map<String, MemberProfile>? memberProfiles,
  }) {
    return AppLeagueExists(
      leagues: leagues ?? this.leagues,
      selectedLeague: selectedLeague ?? this.selectedLeague,
      memberProfiles: memberProfiles ?? this.memberProfiles,
    );
  }
}
