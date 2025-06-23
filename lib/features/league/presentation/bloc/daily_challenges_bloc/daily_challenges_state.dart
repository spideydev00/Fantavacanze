import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';

abstract class DailyChallengesState extends Equatable {
  const DailyChallengesState();

  @override
  List<Object?> get props => [];
}

class DailyChallengesInitial extends DailyChallengesState {
  const DailyChallengesInitial();
}

class DailyChallengesLoading extends DailyChallengesState {
  const DailyChallengesLoading();
}

class DailyChallengesError extends DailyChallengesState {
  final String message;

  const DailyChallengesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DailyChallengesLoaded extends DailyChallengesState {
  final List<DailyChallenge> challenges;
  final String leagueId;
  final String userId;
  final String? operation;

  const DailyChallengesLoaded({
    required this.challenges,
    required this.leagueId,
    required this.userId,
    this.operation,
  });

  @override
  List<Object?> get props => [
        challenges,
        leagueId,
        userId,
        operation,
      ];

  DailyChallengesLoaded copyWith({
    List<DailyChallenge>? challenges,
    String? leagueId,
    String? userId,
    DailyChallenge? lastCompletedChallenge,
    DailyChallenge? lastRefreshedChallenge,
    DailyChallenge? lastUnlockedChallenge,
    String? operation,
  }) {
    return DailyChallengesLoaded(
      challenges: challenges ?? this.challenges,
      leagueId: leagueId ?? this.leagueId,
      userId: userId ?? this.userId,
      operation: operation,
    );
  }

  // Helper per resettare i flag delle operazioni
  DailyChallengesLoaded clearOperations() {
    return DailyChallengesLoaded(
      challenges: challenges,
      leagueId: leagueId,
      userId: userId,
    );
  }
}
