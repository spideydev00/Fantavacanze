import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
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

  Event copyWith({
    String? id,
    String? name,
    double? points,
    String? creatorId,
    String? targetUser,
    DateTime? createdAt,
    RuleType? type,
    String? description,
    bool? isTeamMember,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      creatorId: creatorId ?? this.creatorId,
      targetUser: targetUser ?? this.targetUser,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isTeamMember: isTeamMember ?? this.isTeamMember,
      description: description ?? this.description,
    );
  }
}
