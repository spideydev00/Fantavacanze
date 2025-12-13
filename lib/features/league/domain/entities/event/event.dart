import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/foundation.dart';

enum EventTargetKind { individual, team, teamMember }

@immutable
class EventTarget extends Equatable {
  final EventTargetKind kind;
  final String? userId;
  final String? teamName;
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

  @override
  List<Object?> get props => [kind, userId, teamName, memberId];
}

@immutable
class Event extends Equatable {
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

  Event copyWith({
    String? id,
    String? name,
    double? points,
    String? creatorId,
    EventTarget? target,
    DateTime? createdAt,
    RuleType? type,
    String? description,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      creatorId: creatorId ?? this.creatorId,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  // Derived helpers for convenience
  String get targetUser =>
      target.memberId ?? target.userId ?? target.teamName ?? '';

  bool get isTeamMember => target.kind == EventTargetKind.teamMember;

  String? get targetTeamName => target.teamName;

  @override
  List<Object?> get props => [
        id,
        name,
        points,
        creatorId,
        target,
        createdAt,
        type,
        description,
      ];
}
