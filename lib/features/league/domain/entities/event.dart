import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 19)
enum EventTargetKind {
  @HiveField(0)
  individual,

  @HiveField(1)
  team,

  @HiveField(2)
  teamMember
}

@immutable
@HiveType(typeId: 20)
class EventTarget {
  @HiveField(0)
  final EventTargetKind kind;
  @HiveField(1)
  final String? userId;
  @HiveField(2)
  final String? teamName;
  @HiveField(3)
  final String? memberId;

  const EventTarget({
    required this.kind,
    this.userId,
    this.teamName,
    this.memberId,
  });

  EventTarget copyWith({
    EventTargetKind? kind,
    String? userId,
    String? teamName,
    String? memberId,
  }) {
    return EventTarget(
      kind: kind ?? this.kind,
      userId: userId ?? this.userId,
      teamName: teamName ?? this.teamName,
      memberId: memberId ?? this.memberId,
    );
  }
}

@immutable
class Event {
  final String id;
  final String name;
  final double points;
  final String creatorId;
  final EventTarget target;
  final DateTime createdAt;
  final RuleType type;
  final String? description;

  const Event({
    required this.id,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.target,
    required this.createdAt,
    required this.type,
    this.description,
  });

  /// Compatibility helpers for legacy usages
  String get targetUser =>
      target.memberId ?? target.userId ?? target.teamName ?? '';

  bool get isTeamMember => target.kind == EventTargetKind.teamMember;

  String? get targetTeamName => target.teamName;

  Event copyWith({
    String? id,
    String? name,
    double? points,
    String? creatorId,
    EventTarget? target,
    DateTime? createdAt,
    RuleType? type,
    String? description,
    String? targetUser, // legacy override for user/member id
  }) {
    final newTarget = target ??
        (targetUser != null
            ? this.target.copyWith(
                  userId: this.target.kind == EventTargetKind.teamMember
                      ? this.target.userId
                      : targetUser,
                  memberId: this.target.kind == EventTargetKind.teamMember
                      ? targetUser
                      : this.target.memberId,
                  teamName: this.target.teamName,
                  kind: this.target.kind,
                )
            : this.target);
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      creatorId: creatorId ?? this.creatorId,
      target: newTarget,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }
}
