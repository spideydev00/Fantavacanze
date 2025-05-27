import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';

enum NotificationType {
  challengeCompletion,
  teamInvite,
  general,
}

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
    super.userId,
    super.leagueId,
    super.challengeId,
    super.challengeName,
    super.challengePoints,
    required super.targetUserId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse the notification type from string
    NotificationType type;
    switch (json['type']) {
      case 'challengeCompletion':
        type = NotificationType.challengeCompletion;
        break;
      case 'teamInvite':
        type = NotificationType.teamInvite;
        break;
      default:
        type = NotificationType.general;
    }

    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: type,
      userId: json['user_id'],
      leagueId: json['league_id'],
      challengeId: json['challenge_id'],
      challengeName: json['challenge_name'],
      challengePoints: json['challenge_points'] != null
          ? (json['challenge_points'] as num).toDouble()
          : null,
      targetUserId: json['target_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case NotificationType.challengeCompletion:
        typeString = 'challengeCompletion';
        break;
      case NotificationType.teamInvite:
        typeString = 'teamInvite';
        break;
      default:
        typeString = 'general';
    }

    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': typeString,
      'user_id': userId,
      'league_id': leagueId,
      'challenge_id': challengeId,
      'challenge_name': challengeName,
      'challenge_points': challengePoints,
      'target_user_id': targetUserId,
    };
  }
}
