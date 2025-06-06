import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';

class DailyChallengeNotification extends Notification {
  final String userId;
  final String challengeId;
  final String challengeName;
  final double challengePoints;
  final List<String> targetUserIds;

  const DailyChallengeNotification({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
    required super.leagueId,
    required this.userId,
    required this.challengeId,
    required this.challengeName,
    required this.challengePoints,
    required this.targetUserIds,
  });

  @override
  DailyChallengeNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? leagueId,
    String? userId,
    String? challengeId,
    String? challengeName,
    double? challengePoints,
    List<String>? targetUserIds,
  }) {
    return DailyChallengeNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      leagueId: leagueId ?? this.leagueId,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      challengeName: challengeName ?? this.challengeName,
      challengePoints: challengePoints ?? this.challengePoints,
      targetUserIds: targetUserIds ?? this.targetUserIds,
    );
  }
}
