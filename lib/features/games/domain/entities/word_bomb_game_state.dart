import 'package:equatable/equatable.dart';
import 'dart:math';

class WordBombGameState extends Equatable {
  final String currentCategory;
  final String currentLetterSyllable;
  final List<String> usedWords;
  final int currentTurnTotalDurationMs;
  final int roundStartTimeEpochMs;
  final bool isPaused;
  final String? ghostPlayerId;
  final String? playerWhoExplodedId;
  final int buyTimeUsesLeftForRound;
  final bool isGhostProtocolActive;
  final int? pauseTimeEpochMs;
  final int timeAccumulatedWhilePausedMs;
  final int? ghostProtocolActivationTimeEpochMs;

  const WordBombGameState({
    required this.currentCategory,
    required this.currentLetterSyllable,
    required this.usedWords,
    required this.currentTurnTotalDurationMs,
    required this.roundStartTimeEpochMs,
    this.isPaused = false,
    this.ghostPlayerId,
    this.playerWhoExplodedId,
    this.buyTimeUsesLeftForRound = 2,
    this.isGhostProtocolActive = false,
    this.pauseTimeEpochMs,
    this.timeAccumulatedWhilePausedMs = 0,
    this.ghostProtocolActivationTimeEpochMs,
  });

  factory WordBombGameState.fromJson(Map<String, dynamic> json) {
    return WordBombGameState(
      currentCategory: json['current_category'] as String? ?? "Sconosciuta",
      currentLetterSyllable: json['current_letter_syllable'] as String? ?? "A",
      usedWords: (json['used_words'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentTurnTotalDurationMs:
          json['current_turn_total_duration_ms'] as int? ?? 30000,
      roundStartTimeEpochMs: json['round_start_time_epoch_ms'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
      isPaused: json['is_paused'] as bool? ?? false,
      ghostPlayerId: json['ghost_player_id'] as String?,
      playerWhoExplodedId: json['player_who_exploded_id'] as String?,
      buyTimeUsesLeftForRound:
          json['buy_time_uses_left_for_round'] as int? ?? 2,
      isGhostProtocolActive: json['is_ghost_protocol_active'] as bool? ?? false,
      pauseTimeEpochMs: json['pause_time_epoch_ms'] as int?,
      timeAccumulatedWhilePausedMs:
          json['time_accumulated_while_paused_ms'] as int? ?? 0,
      ghostProtocolActivationTimeEpochMs:
          json['ghost_protocol_activation_time_epoch_ms'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_category': currentCategory,
      'current_letter_syllable': currentLetterSyllable,
      'used_words': usedWords,
      'current_turn_total_duration_ms': currentTurnTotalDurationMs,
      'round_start_time_epoch_ms': roundStartTimeEpochMs,
      'is_paused': isPaused,
      'ghost_player_id': ghostPlayerId,
      'player_who_exploded_id': playerWhoExplodedId,
      'buy_time_uses_left_for_round': buyTimeUsesLeftForRound,
      'is_ghost_protocol_active': isGhostProtocolActive,
      'pause_time_epoch_ms': pauseTimeEpochMs,
      'time_accumulated_while_paused_ms': timeAccumulatedWhilePausedMs,
      'ghost_protocol_activation_time_epoch_ms':
          ghostProtocolActivationTimeEpochMs,
    };
  }

  WordBombGameState copyWith({
    String? currentCategory,
    String? currentLetterSyllable,
    List<String>? usedWords,
    int? currentTurnTotalDurationMs,
    int? roundStartTimeEpochMs,
    bool? isPaused,
    String? ghostPlayerId,
    bool clearGhostPlayerId = false,
    String? playerWhoExplodedId,
    bool clearPlayerWhoExplodedId = false,
    int? buyTimeUsesLeftForRound,
    bool? isGhostProtocolActive,
    int? pauseTimeEpochMs,
    bool clearPauseTimeEpochMs = false,
    int? timeAccumulatedWhilePausedMs,
    int? ghostProtocolActivationTimeEpochMs,
    bool clearGhostProtocolActivationTimeEpochMs = false,
  }) {
    return WordBombGameState(
      currentCategory: currentCategory ?? this.currentCategory,
      currentLetterSyllable:
          currentLetterSyllable ?? this.currentLetterSyllable,
      usedWords: usedWords ?? this.usedWords,
      currentTurnTotalDurationMs:
          currentTurnTotalDurationMs ?? this.currentTurnTotalDurationMs,
      roundStartTimeEpochMs:
          roundStartTimeEpochMs ?? this.roundStartTimeEpochMs,
      isPaused: isPaused ?? this.isPaused,
      ghostPlayerId:
          clearGhostPlayerId ? null : ghostPlayerId ?? this.ghostPlayerId,
      playerWhoExplodedId: clearPlayerWhoExplodedId
          ? null
          : playerWhoExplodedId ?? this.playerWhoExplodedId,
      buyTimeUsesLeftForRound:
          buyTimeUsesLeftForRound ?? this.buyTimeUsesLeftForRound,
      isGhostProtocolActive:
          isGhostProtocolActive ?? this.isGhostProtocolActive,
      pauseTimeEpochMs: clearPauseTimeEpochMs
          ? null
          : pauseTimeEpochMs ?? this.pauseTimeEpochMs,
      timeAccumulatedWhilePausedMs:
          timeAccumulatedWhilePausedMs ?? this.timeAccumulatedWhilePausedMs,
      ghostProtocolActivationTimeEpochMs:
          clearGhostProtocolActivationTimeEpochMs
              ? null
              : ghostProtocolActivationTimeEpochMs ??
                  this.ghostProtocolActivationTimeEpochMs,
    );
  }

  @override
  List<Object?> get props => [
        currentCategory,
        currentLetterSyllable,
        usedWords,
        currentTurnTotalDurationMs,
        roundStartTimeEpochMs,
        isPaused,
        ghostPlayerId,
        playerWhoExplodedId,
        buyTimeUsesLeftForRound,
        isGhostProtocolActive,
        pauseTimeEpochMs,
        timeAccumulatedWhilePausedMs,
        ghostProtocolActivationTimeEpochMs,
      ];

  int get calculatedRemainingTimeMs {
    if (playerWhoExplodedId != null) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (isPaused) {
      // If paused, the time "stops" at the moment it was paused.
      // pauseTimeEpochMs should be non-null if isPaused is true.
      final effectivePauseStartTime = pauseTimeEpochMs ??
          now; // Fallback, though pauseTimeEpochMs should be set
      final elapsedBeforeThisPause = effectivePauseStartTime -
          roundStartTimeEpochMs -
          timeAccumulatedWhilePausedMs;
      return max(0, currentTurnTotalDurationMs - elapsedBeforeThisPause);
    }

    // If active (not paused)
    final effectiveElapsedTime =
        now - roundStartTimeEpochMs - timeAccumulatedWhilePausedMs;
    return max(0, currentTurnTotalDurationMs - effectiveElapsedTime);
  }

  // Getter for UI to determine if timer should be hidden due to active Ghost Protocol
  bool get isGhostTimerCurrentlyHidden {
    if (!isGhostProtocolActive || ghostProtocolActivationTimeEpochMs == null) {
      return false; // Protocol not active or no activation timestamp
    }
    // Check if current time is within 30 seconds of activation time
    return (DateTime.now().millisecondsSinceEpoch -
            ghostProtocolActivationTimeEpochMs!) <
        30000; // 30 seconds
  }
}
