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
    required super.isTeamMember,
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
      final pointsValue = _extractPointsValue(json['points']);
      eventType = pointsValue >= 0 ? RuleType.bonus : RuleType.malus;
    }

    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: _extractPointsValue(json['points']),
      creatorId: json['creatorId'] as String,
      targetUser: json['targetUser'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: eventType,
      description: json['description'] as String?,
      isTeamMember: json['isTeamMember'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'creatorId': creatorId,
      'targetUser': targetUser,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
      'isTeamMember': isTeamMember,
    };
  }

  // Helper method to safely extract points value as double
  static double _extractPointsValue(dynamic pointsData) {
    if (pointsData is int) {
      return pointsData.toDouble();
    } else if (pointsData is double) {
      return pointsData;
    } else if (pointsData is String) {
      return double.tryParse(pointsData) ?? 0.0;
    }
    return 0.0;
  }
}
