import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

abstract class LeagueState extends Equatable {
  const LeagueState();

  @override
  List<Object?> get props => [];
}

class LeagueInitial extends LeagueState {
  const LeagueInitial();
}

class LeagueLoading extends LeagueState {
  const LeagueLoading();
}

class LeagueError extends LeagueState {
  final String message;

  const LeagueError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeagueCreated extends LeagueState {
  final League league;

  const LeagueCreated({required this.league});

  @override
  List<Object?> get props => [league];
}

class LeagueLoaded extends LeagueState {
  final League league;

  const LeagueLoaded({required this.league});

  @override
  List<Object?> get props => [league];
}

class UserLeaguesLoaded extends LeagueState {
  final List<League> leagues;

  const UserLeaguesLoaded({required this.leagues});

  @override
  List<Object?> get props => [leagues];
}

class LeagueJoined extends LeagueState {
  final League league;

  const LeagueJoined({required this.league});

  @override
  List<Object?> get props => [league];
}

class LeagueExited extends LeagueState {
  final League league;

  const LeagueExited({required this.league});

  @override
  List<Object?> get props => [league];
}

class TeamNameUpdated extends LeagueState {
  final League league;

  const TeamNameUpdated({required this.league});

  @override
  List<Object?> get props => [league];
}

class EventAdded extends LeagueState {
  final League league;

  const EventAdded({required this.league});

  @override
  List<Object?> get props => [league];
}

class MemoryAdded extends LeagueState {
  final League league;

  const MemoryAdded({required this.league});

  @override
  List<Object?> get props => [league];
}

class MultiplePossibleLeagues extends LeagueState {
  final String inviteCode;
  final List<dynamic> possibleLeagues;

  const MultiplePossibleLeagues({
    required this.inviteCode,
    required this.possibleLeagues,
  });

  @override
  List<Object?> get props => [inviteCode, possibleLeagues];
}
