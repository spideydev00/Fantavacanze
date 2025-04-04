import 'package:fantavacanze_official/features/league/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.name,
    required super.points,
    required super.userId,
    required super.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
