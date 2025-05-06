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
