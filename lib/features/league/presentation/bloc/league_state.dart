import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

class DeleteLeagueSuccess extends LeagueState {}

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

class TeammatesRemovedState extends LeagueState {
  final League league;

  const TeammatesRemovedState({required this.league});

  @override
  List<Object?> get props => [league];
}

// Replace the three note-specific states with a single success state
class NoteSuccess extends LeagueState {
  final String operation; // "get", "save", or "delete"
  final List<NoteModel>? notes;
  final String leagueId;

  const NoteSuccess({
    required this.operation,
    required this.leagueId,
    this.notes,
  });

  @override
  List<Object?> get props => [operation, leagueId, notes];
}

// Add new state for image upload success
class ImageUploadSuccess extends LeagueState {
  final String imageUrl;

  const ImageUploadSuccess({required this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class TeamLogoUploadSuccess extends LeagueState {
  final String logoUrl;
  final String teamName;

  const TeamLogoUploadSuccess({
    required this.logoUrl,
    required this.teamName,
  });

  @override
  List<Object?> get props => [logoUrl, teamName];
}

class AdminOperationSuccess extends LeagueState {
  final League league;
  final String operation;

  const AdminOperationSuccess({
    required this.league,
    required this.operation,
  });

  @override
  List<Object> get props => [league, operation];
}

// Daily challenge states
class DailyChallengesLoaded extends LeagueState {
  final List<DailyChallenge> challenges;

  const DailyChallengesLoaded({
    required this.challenges,
  });

  @override
  List<Object?> get props => [challenges];
}

class ChallengeMarkedAsCompleted extends LeagueState {
  final DailyChallenge challenge;

  const ChallengeMarkedAsCompleted({
    required this.challenge,
  });

  @override
  List<Object?> get props => [challenge];
}

class ChallengeRefreshed extends LeagueState {
  final String challengeId;

  const ChallengeRefreshed({
    required this.challengeId,
  });

  @override
  List<Object?> get props => [challengeId];
}

class NotificationReceived extends LeagueState {
  final RemoteNotification notification;
  final Map<String, dynamic>? data;

  const NotificationReceived({
    required this.notification,
    this.data,
  });

  @override
  List<Object?> get props => [notification, data];
}

class NotificationsLoaded extends LeagueState {
  final List<Notification> notifications;

  const NotificationsLoaded({
    required this.notifications,
  });

  @override
  List<Object?> get props => [notifications];
}

class NotificationActionSuccess extends LeagueState {
  final String action;
  final String? notificationId;

  const NotificationActionSuccess({
    required this.action,
    this.notificationId,
  });

  @override
  List<Object?> get props => [action, notificationId];
}
