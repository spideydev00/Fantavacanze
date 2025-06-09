import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';

class GamePlayerModel extends GamePlayer {
  const GamePlayerModel({
    required super.id,
    required super.sessionId,
    required super.userId,
    required super.userName,
    required super.score,
    required super.isGhost,
    required super.hasUsedSpecialAbility,
    required super.hasUsedGhostProtocol,
    required super.changeCategoryUsesLeft,
    required super.joinedAt,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> map) {
    return GamePlayerModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      userId: map['user_id'] as String,
      userName: map['name'] as String? ??
          map['profiles']['name'] as String? ??
          'Giocatore',
      score: map['score'] as int? ?? 0,
      isGhost: map['is_ghost'] as bool? ?? false,
      hasUsedSpecialAbility: map['has_used_special_ability'] as bool? ?? false,
      hasUsedGhostProtocol: map['has_used_ghost_protocol'] as bool? ?? false,
      changeCategoryUsesLeft: map['change_category_uses_left'] as int? ?? 2,
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'score': score,
      'is_ghost': isGhost,
      'has_used_special_ability': hasUsedSpecialAbility,
      'has_used_ghost_protocol': hasUsedGhostProtocol,
      'change_category_uses_left': changeCategoryUsesLeft,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  @override
  GamePlayerModel copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft,
    DateTime? joinedAt,
  }) {
    return GamePlayerModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      score: score ?? this.score,
      isGhost: isGhost ?? this.isGhost,
      hasUsedSpecialAbility:
          hasUsedSpecialAbility ?? this.hasUsedSpecialAbility,
      hasUsedGhostProtocol: hasUsedGhostProtocol ?? this.hasUsedGhostProtocol,
      changeCategoryUsesLeft:
          changeCategoryUsesLeft ?? this.changeCategoryUsesLeft,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
