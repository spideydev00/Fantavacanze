import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String name;
  final int points;
  final String creatorId; // ID of the admin who created the event
  final String targetUser; // The user receiving the points
  final DateTime createdAt;
  final RuleType type;
  final String? description;

  const Event({
    required this.id,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUser,
    required this.createdAt,
    required this.type,
    this.description,
  });
}
