import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.name,
    required super.points,
    required super.creatorId,
    required super.targetUser,
    required super.createdAt,
    required super.type,
    super.description,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Determine type based on points or explicitly from JSON
    RuleType eventType;
    if (json['type'] != null) {
      // If type is explicitly provided in JSON
      eventType = json['type'].toString().toLowerCase() == 'bonus'
          ? RuleType.bonus
          : RuleType.malus;
    } else {
      // Default behavior: determine by points
      eventType =
          (json['points'] as int) >= 0 ? RuleType.bonus : RuleType.malus;
    }

    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      creatorId: json['creatorId'] as String,
      targetUser: json['targetUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: eventType,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'creatorId': creatorId,
      'targetUserId': targetUser,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
    };
  }
}
