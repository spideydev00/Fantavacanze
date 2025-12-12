import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 2)
class EventModel extends Event {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get points => super.points;

  @HiveField(3)
  @override
  String get creatorId => super.creatorId;

  @HiveField(4)
  EventTargetKind get hiveTargetKind => target.kind;

  @HiveField(5)
  String? get hiveTargetUserId => target.userId;

  @HiveField(6)
  String? get hiveTargetTeamName => target.teamName;

  @HiveField(7)
  String? get hiveTargetMemberId => target.memberId;

  @HiveField(8)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(9)
  @override
  RuleType get type => super.type;

  @HiveField(10)
  @override
  String? get description => super.description;

  const EventModel({
    required super.id,
    required super.name,
    required super.points,
    required super.creatorId,
    required super.target,
    required super.createdAt,
    required super.type,
    super.description,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final targetData = json['target'];
    String? targetTeamName;
    String? targetUserId;
    String? targetMemberId;
    EventTargetKind targetKind = EventTargetKind.individual;

    if (targetData is Map<String, dynamic>) {
      targetTeamName = targetData['team_name'] as String? ??
          targetData['teamName'] as String?;
      final rawKind =
          (targetData['kind'] ?? targetData['target_kind']) as String?;
      targetKind = _mapTargetKind(rawKind);

      targetMemberId = (targetData['member_id'] ??
              targetData['memberId'] ??
              targetData['target_member_id'])
          as String?;
      targetUserId = (targetData['user_id'] ??
          targetData['userId'] ??
          targetData['target_user_id'] ??
          targetData['target']) as String?;
    } else {
      targetTeamName = json['targetTeamName'] as String?;
      final rawTarget = json['targetUser'] ?? json['target_user'];
      targetUserId = rawTarget as String?;
      final rawKind = json['targetKind'] ?? json['target_kind'];
      if (rawKind is String) {
        targetKind = _mapTargetKind(rawKind);
      } else if (targetTeamName != null && targetTeamName.isNotEmpty) {
        targetKind = EventTargetKind.team;
      } else {
        targetKind = EventTargetKind.individual;
      }
    }
    final isTeamMember =
        (json['isTeamMember'] ?? json['is_team_member']) as bool?;
    if (isTeamMember == true) {
      targetKind = EventTargetKind.teamMember;
      targetMemberId ??= targetUserId;
    }

    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.parse(createdAtRaw)
        : (createdAtRaw is DateTime ? createdAtRaw : DateTime.now());

    // Determine type based on points or explicitly from JSON
    RuleType eventType;
    if (json['type'] != null) {
      eventType = json['type'].toString().toLowerCase() == 'bonus'
          ? RuleType.bonus
          : RuleType.malus;
    } else {
      final pointsValue = _extractPointsValue(json['points']);
      eventType = pointsValue >= 0 ? RuleType.bonus : RuleType.malus;
    }

    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: _extractPointsValue(json['points']),
      creatorId: (json['creatorId'] ?? json['creator_id']) as String,
      target: EventTarget(
        kind: targetKind,
        userId: targetUserId,
        teamName: targetTeamName,
        memberId: targetMemberId,
      ),
      createdAt: createdAt,
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
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
      'target': {
        'kind': target.kind.name,
        'team_name': target.teamName,
        'user_id': target.userId,
        'member_id': target.memberId,
        'target_member_id': target.memberId,
        'target_team_name': target.teamName,
      },
    };
  }

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

  static EventTargetKind _mapTargetKind(String? rawKind) {
    switch (rawKind?.toLowerCase()) {
      case 'team':
        return EventTargetKind.team;
      case 'team_member':
      case 'teammember':
      case 'member':
        return EventTargetKind.teamMember;
      default:
        return EventTargetKind.individual;
    }
  }
}
