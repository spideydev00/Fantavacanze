import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:hive/hive.dart';

part 'daily_challenge_notification_model.g.dart';

@HiveType(typeId: 7)
class DailyChallengeNotificationModel extends DailyChallengeNotification
    implements NotificationModel {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get title => super.title;

  @HiveField(2)
  @override
  String get message => super.message;

  @HiveField(3)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(4)
  @override
  bool get isRead => super.isRead;

  @HiveField(5)
  @override
  String get type => super.type;

  @HiveField(6)
  @override
  String get userId => super.userId;

  @HiveField(7)
  @override
  String get leagueId => super.leagueId;

  @HiveField(8)
  @override
  String get challengeId => super.challengeId;

  @HiveField(9)
  @override
  String get challengeName => super.challengeName;

  @HiveField(10)
  @override
  double get challengePoints => super.challengePoints;

  @HiveField(11)
  @override
  List<String> get targetUserIds => super.targetUserIds;

  const DailyChallengeNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
    required super.userId,
    required super.leagueId,
    required super.challengeId,
    required super.challengeName,
    required super.challengePoints,
    required super.targetUserIds,
  });

  factory DailyChallengeNotificationModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeNotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: json['type'],
      userId: json['user_id'],
      leagueId: json['league_id'],
      challengeId: json['challenge_id'],
      challengeName: json['challenge_name'],
      challengePoints: json['challenge_points'] is int
          ? (json['challenge_points'] as int).toDouble()
          : (json['challenge_points'] as num).toDouble(),
      targetUserIds: List<String>.from(json['target_user_ids'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'user_id': userId,
      'league_id': leagueId,
      'challenge_id': challengeId,
      'challenge_name': challengeName,
      'challenge_points': challengePoints,
      'target_user_ids': targetUserIds,
    };
  }
}
