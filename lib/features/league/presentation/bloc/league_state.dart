import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

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

/// A unified state for all operations that return a League entity
class LeagueSuccess extends LeagueState {
  final League league;
  final String? operation;

  const LeagueSuccess({
    required this.league,
    this.operation,
  });

  @override
  List<Object?> get props => [league, operation];
}

class ExitLeagueSuccess extends LeagueState {}

class LeagueWithInviteCode extends LeagueState {
  final League league;
  final String inviteCode;

  const LeagueWithInviteCode({
    required this.league,
    required this.inviteCode,
  });

  @override
  List<Object?> get props => [league, inviteCode];
}

class MultiplePossibleLeagues extends LeagueState {
  final List<League> possibleLeagues;
  final String inviteCode;

  const MultiplePossibleLeagues({
    required this.possibleLeagues,
    required this.inviteCode,
  });

  @override
  List<Object?> get props => [possibleLeagues, inviteCode];
}

class RulesLoaded extends LeagueState {
  final List<Rule> rules;
  final String mode;

  const RulesLoaded({
    required this.rules,
    required this.mode,
  });

  @override
  List<Object?> get props => [rules, mode];
}

class UsersDetailsLoaded extends LeagueState {
  final List<Map<String, dynamic>> usersDetails;

  const UsersDetailsLoaded({
    required this.usersDetails,
  });

  @override
  List<Object?> get props => [usersDetails];
}

class TeammatesRemovedState extends LeagueState {
  final League league;

  const TeammatesRemovedState({required this.league});

  @override
  List<Object?> get props => [league];
}
