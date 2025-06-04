import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 8)
class NotificationModel extends Notification {
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
  String get leagueId => super.leagueId;

  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
    required super.leagueId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: json['type'],
      leagueId: json['league_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'league_id': leagueId,
    };
  }
}
