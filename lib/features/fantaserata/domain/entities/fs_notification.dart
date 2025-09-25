import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart';

class FsEventNotification extends Notification {
  final String userName;
  final double challengePoints;

  const FsEventNotification({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.leagueId,
    required this.userName,
    required this.challengePoints, // Based on this value (negative or positive) the notification will differ
  });

  @override
  FsEventNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    String? leagueId,
    String? userName,
    double? challengePoints,
  }) {
    return FsEventNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      leagueId: leagueId ?? this.leagueId,
      userName: userName ?? this.userName,
      challengePoints: challengePoints ?? this.challengePoints,
    );
  }
}
