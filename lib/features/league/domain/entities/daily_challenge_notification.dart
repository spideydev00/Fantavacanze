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
}
