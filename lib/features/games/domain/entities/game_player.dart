import 'package:equatable/equatable.dart';

class GamePlayer extends Equatable {
  final String id; // Record ID
  final String sessionId;
  final String userId;
  final String userName; // Denormalized for easier display
  final String? userAvatarUrl; // Denormalized
  final int score;
  final bool isGhost; // Specific to Word Bomb
  final bool hasUsedSpecialAbility; // Specific to Word Bomb
  final DateTime joinedAt;

  const GamePlayer({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.score = 0,
    this.isGhost = false,
    this.hasUsedSpecialAbility = false,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        userName,
        userAvatarUrl,
        score,
        isGhost,
        hasUsedSpecialAbility,
        joinedAt,
      ];

  GamePlayer copyWith({
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
    return GamePlayer(
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
