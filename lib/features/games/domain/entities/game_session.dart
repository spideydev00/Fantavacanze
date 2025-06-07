import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';

class GameSession extends Equatable {
  final String id;
  final String inviteCode;
  final String adminId;
  final GameType gameType;
  final GameStatus status;
  final String? currentTurnUserId;
  final Map<String, dynamic>?
      gameState; // Flexible JSONB for game-specific data
  final DateTime createdAt;

  const GameSession({
    required this.id,
    required this.inviteCode,
    required this.adminId,
    required this.gameType,
    required this.status,
    this.currentTurnUserId,
    this.gameState,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        inviteCode,
        adminId,
        gameType,
        status,
        currentTurnUserId,
        gameState,
        createdAt,
      ];

  GameSession copyWith({
    String? id,
    String? inviteCode,
    String? adminId,
    GameType? gameType,
    GameStatus? status,
    String? currentTurnUserId,
    Map<String, dynamic>? gameState,
    DateTime? createdAt,
  }) {
    return GameSession(
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
