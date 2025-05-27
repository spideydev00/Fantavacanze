import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final dynamic type;
  final String? userId;
  final String? leagueId;
  final String? challengeId;
  final String? challengeName;
  final double? challengePoints;
  final String targetUserId;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.userId,
    this.leagueId,
    this.challengeId,
    this.challengeName,
    this.challengePoints,
    required this.targetUserId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        createdAt,
        isRead,
        type,
        userId,
        leagueId,
        challengeId,
        challengeName,
        challengePoints,
        targetUserId,
      ];
}
