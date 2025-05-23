import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String name;
  final double points;
  final String creatorId;
  final String targetUser;
  final DateTime createdAt;
  final RuleType type;
  final String? description;
  final bool isTeamMember;

  const Event({
    required this.id,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUser,
    required this.createdAt,
    required this.type,
    required this.isTeamMember,
    this.description,
  });
}
