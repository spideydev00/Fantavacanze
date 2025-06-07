import 'package:fantavacanze_official/features/games/domain/entities/word_bomb_game_state.dart';

const int _defaultWordBombTurnDurationMs = 10000;

class WordBombGameStateModel extends WordBombGameState {
  const WordBombGameStateModel({
    required super.currentCategory,
    required super.currentLetterSyllable,
    required super.usedWords,
    required super.remainingTimeMs,
    required super.isPaused,
    super.ghostPlayerId,
    required super.totalTurnTimeMs,
  });

  factory WordBombGameStateModel.fromJson(Map<String, dynamic> json) {
    return WordBombGameStateModel(
      currentCategory: json['currentCategory'] as String,
      currentLetterSyllable: json['currentLetterSyllable'] as String,
      usedWords:
          (json['usedWords'] as List<dynamic>).map((e) => e as String).toList(),
      remainingTimeMs: json['remainingTimeMs'] as int,
      isPaused: json['isPaused'] as bool,
      ghostPlayerId: json['ghostPlayerId'] as String?,
      totalTurnTimeMs:
          json['totalTurnTimeMs'] as int? ?? _defaultWordBombTurnDurationMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentCategory': currentCategory,
      'currentLetterSyllable': currentLetterSyllable,
      'usedWords': usedWords,
      'remainingTimeMs': remainingTimeMs,
      'isPaused': isPaused,
      'ghostPlayerId': ghostPlayerId,
      'totalTurnTimeMs': totalTurnTimeMs,
    };
  }

  @override
  WordBombGameStateModel copyWith({
    String? currentCategory,
    String? currentLetterSyllable,
    List<String>? usedWords,
    int? remainingTimeMs,
    bool? isPaused,
    String? ghostPlayerId,
    bool clearGhostPlayerId = false,
    int? totalTurnTimeMs,
  }) {
    return WordBombGameStateModel(
      currentCategory: currentCategory ?? this.currentCategory,
      currentLetterSyllable:
          currentLetterSyllable ?? this.currentLetterSyllable,
      usedWords: usedWords ?? this.usedWords,
      remainingTimeMs: remainingTimeMs ?? this.remainingTimeMs,
      isPaused: isPaused ?? this.isPaused,
      ghostPlayerId:
          clearGhostPlayerId ? null : ghostPlayerId ?? this.ghostPlayerId,
      totalTurnTimeMs: totalTurnTimeMs ?? this.totalTurnTimeMs,
    );
  }
}
