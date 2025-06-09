import 'package:equatable/equatable.dart';

class GamePlayer extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final int score;
  final bool isGhost;
  final bool hasUsedSpecialAbility;
  final bool hasUsedGhostProtocol;
  final int changeCategoryUsesLeft;
  final DateTime joinedAt;

  static const int defaultChangeCategoryUses = 2;

  const GamePlayer({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.score = 0,
    this.isGhost = false,
    this.hasUsedSpecialAbility = false,
    this.hasUsedGhostProtocol = false,
    this.changeCategoryUsesLeft = defaultChangeCategoryUses,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        userName,
        score,
        isGhost,
        hasUsedSpecialAbility,
        hasUsedGhostProtocol,
        changeCategoryUsesLeft, // Add to props
        joinedAt,
      ];

  GamePlayer copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? userName,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft, // Add to copyWith
    DateTime? joinedAt,
  }) {
    return GamePlayer(
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
