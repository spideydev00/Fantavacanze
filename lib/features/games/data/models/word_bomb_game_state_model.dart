import 'package:fantavacanze_official/features/games/domain/entities/word_bomb_game_state.dart';

class WordBombGameStateModel extends WordBombGameState {
  const WordBombGameStateModel({
    required super.currentCategory,
    required super.currentLetterSyllable,
    required super.usedWords,
    required super.currentTurnTotalDurationMs,
    required super.roundStartTimeEpochMs,
    required super.isPaused,
    super.playerWhoExplodedId,
    super.ghostPlayerId,
    super.isGhostProtocolActive,
    required super.buyTimeUsesLeftForRound,
    super.pauseTimeEpochMs,
    required super.timeAccumulatedWhilePausedMs,
    super.ghostProtocolActivationTimeEpochMs,
  });

  factory WordBombGameStateModel.fromJson(Map<String, dynamic> json) {
    return WordBombGameStateModel(
      currentCategory: json['current_category'] as String,
      currentLetterSyllable: json['current_letter_syllable'] as String,
      usedWords: (json['used_words'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentTurnTotalDurationMs:
          json['current_turn_total_duration_ms'] as int? ?? 60000,
      roundStartTimeEpochMs: json['round_start_time_epoch_ms'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
      isPaused: json['is_paused'] as bool? ?? false,
      playerWhoExplodedId: json['player_who_exploded_id'] as String?,
      ghostPlayerId: json['ghost_player_id'] as String?,
      isGhostProtocolActive: json['is_ghost_protocol_active'] as bool? ?? false,
      buyTimeUsesLeftForRound: json['buy_time_uses_left_for_round'] as int,
      pauseTimeEpochMs: json['pause_time_epoch_ms'] as int?,
      timeAccumulatedWhilePausedMs:
          json['time_accumulated_while_paused_ms'] as int? ?? 0,
      ghostProtocolActivationTimeEpochMs:
          json['ghost_protocol_activation_time_epoch_ms'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'current_category': currentCategory,
      'current_letter_syllable': currentLetterSyllable,
      'used_words': usedWords,
      'current_turn_total_duration_ms': currentTurnTotalDurationMs,
      'round_start_time_epoch_ms': roundStartTimeEpochMs,
      'is_paused': isPaused,
      'player_who_exploded_id': playerWhoExplodedId,
      'ghost_player_id': ghostPlayerId,
      'is_ghost_protocol_active': isGhostProtocolActive,
      'buy_time_uses_left_for_round': buyTimeUsesLeftForRound,
      'pause_time_epoch_ms': pauseTimeEpochMs,
      'time_accumulated_while_paused_ms': timeAccumulatedWhilePausedMs,
      'ghost_protocol_activation_time_epoch_ms':
          ghostProtocolActivationTimeEpochMs,
    };
  }
}

extension WordBombGameStateModelExtension on WordBombGameStateModel {
  static WordBombGameStateModel fromEntity(WordBombGameState entity) {
    return WordBombGameStateModel(
      currentCategory: entity.currentCategory,
      currentLetterSyllable: entity.currentLetterSyllable,
      usedWords: List<String>.from(entity.usedWords),
      currentTurnTotalDurationMs: entity.currentTurnTotalDurationMs,
      roundStartTimeEpochMs: entity.roundStartTimeEpochMs,
      isPaused: entity.isPaused,
      playerWhoExplodedId: entity.playerWhoExplodedId,
      ghostPlayerId: entity.ghostPlayerId,
      isGhostProtocolActive: entity.isGhostProtocolActive,
      buyTimeUsesLeftForRound: entity.buyTimeUsesLeftForRound,
      pauseTimeEpochMs: entity.pauseTimeEpochMs,
      timeAccumulatedWhilePausedMs: entity.timeAccumulatedWhilePausedMs,
      ghostProtocolActivationTimeEpochMs:
          entity.ghostProtocolActivationTimeEpochMs,
    );
  }
}
