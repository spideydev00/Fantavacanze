import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';

class GamePlayerModel extends GamePlayer {
  const GamePlayerModel({
    required super.id,
    required super.sessionId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.score,
    required super.isGhost,
    required super.hasUsedSpecialAbility,
    required super.joinedAt,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> map) {
    // Assuming 'profiles' table is joined or user details are fetched separately
    // and added to the map before calling this factory.
    // For simplicity, we expect userName and userAvatarUrl to be in the map.
    // In a real scenario, you might have a nested 'profiles' object or fetch it.
    return GamePlayerModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      userId: map['user_id'] as String,
      userName: map['profiles']?['name'] ??
          map['user_name'] ??
          'Giocatore', // Example: fetching from a joined 'profiles' table
      userAvatarUrl:
          map['profiles']?['avatar_url'] ?? map['user_avatar_url'] as String?,
      score: map['score'] as int? ?? 0,
      isGhost: map['is_ghost'] as bool? ?? false,
      hasUsedSpecialAbility: map['has_used_special_ability'] as bool? ?? false,
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      // userName and userAvatarUrl are not typically part of game_players table schema for writing,
      // they are for reading (denormalized or joined).
      'score': score,
      'is_ghost': isGhost,
      'has_used_special_ability': hasUsedSpecialAbility,
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
    DateTime? joinedAt,
  }) {
    return GamePlayerModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      score: score ?? this.score,
      isGhost: isGhost ?? this.isGhost,
      hasUsedSpecialAbility:
          hasUsedSpecialAbility ?? this.hasUsedSpecialAbility,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
