import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.inviteCode,
    required super.adminId,
    required super.gameType,
    required super.status,
    super.currentTurnUserId,
    super.gameState,
    required super.createdAt,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> map) {
    return GameSessionModel(
      id: map['id'] as String,
      inviteCode: map['invite_code'] as String,
      adminId: map['admin_id'] as String,
      gameType: gameTypeFromString(map['game_type'] as String),
      status: gameStatusFromString(map['status'] as String),
      currentTurnUserId: map['current_turn_user_id'] as String?,
      gameState: map['game_state'] != null
          ? Map<String, dynamic>.from(map['game_state'] as Map)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'admin_id': adminId,
      'game_type': gameTypeToString(gameType),
      'status': gameStatusToString(status),
      'current_turn_user_id': currentTurnUserId,
      'game_state': gameState,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  GameSessionModel copyWith({
    String? id,
    String? inviteCode,
    String? adminId,
    GameType? gameType,
    GameStatus? status,
    String? currentTurnUserId,
    Map<String, dynamic>? gameState,
    DateTime? createdAt,
  }) {
    return GameSessionModel(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      adminId: adminId ?? this.adminId,
      gameType: gameType ?? this.gameType,
      status: status ?? this.status,
      currentTurnUserId: currentTurnUserId ?? this.currentTurnUserId,
      gameState: gameState ?? this.gameState,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
