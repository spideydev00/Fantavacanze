import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';

abstract class DailyChallengesEvent extends Equatable {
  const DailyChallengesEvent();

  @override
  List<Object?> get props => [];
}

class GetDailyChallengesEvent extends DailyChallengesEvent {
  final String userId;
  final String leagueId;

  const GetDailyChallengesEvent({
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [userId, leagueId];
}

class MarkChallengeAsCompletedEvent extends DailyChallengesEvent {
  final DailyChallenge challenge;
  final String userId;
  final String leagueId;

  const MarkChallengeAsCompletedEvent({
    required this.challenge,
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [challenge, userId, leagueId];
}

class RefreshDailyChallengeEvent extends DailyChallengesEvent {
  final DailyChallenge challenge;
  final String userId;
  final String leagueId;

  const RefreshDailyChallengeEvent({
    required this.challenge,
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [challenge, userId, leagueId];
}

class UnlockDailyChallengeEvent extends DailyChallengesEvent {
  final DailyChallenge challenge;
  final String userId;
  final String leagueId;

  const UnlockDailyChallengeEvent({
    required this.challenge,
    required this.leagueId,
    required this.userId,
  });

  @override
  List<Object?> get props => [challenge, userId, leagueId];
}

class UnlockPremiumChallengesEvent extends DailyChallengesEvent {
  final String userId;
  final String leagueId;

  const UnlockPremiumChallengesEvent({
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [userId, leagueId];
}

class LockPremiumChallengesEvent extends DailyChallengesEvent {
  final String userId;
  final String leagueId;

  const LockPremiumChallengesEvent({
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [userId, leagueId];
}

class ApproveDailyChallengeEvent extends DailyChallengesEvent {
  final String notificationId;

  const ApproveDailyChallengeEvent({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

class RejectDailyChallengeEvent extends DailyChallengesEvent {
  final String notificationId;
  final String challengeId;

  const RejectDailyChallengeEvent({
    required this.notificationId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [notificationId, challengeId];
}

class DailyChallengesResetStateEvent extends DailyChallengesEvent {
  const DailyChallengesResetStateEvent();

  @override
  List<Object?> get props => [];
}
