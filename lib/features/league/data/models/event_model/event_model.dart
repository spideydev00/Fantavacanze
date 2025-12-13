import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:hive/hive.dart';

part 'event_model.g.dart';

// Manual adapter for EventTargetKind (domain enum is now pure)
class EventTargetKindAdapter extends TypeAdapter<EventTargetKind> {
  @override
  final int typeId = 19;

  @override
  EventTargetKind read(BinaryReader reader) {
    final value = reader.read();
    if (value is int) {
      return EventTargetKind.values[value];
    }
    if (value is String) {
      return EventTargetKind.values
          .firstWhere((e) => e.name == value, orElse: () => EventTargetKind.individual);
    }
    return EventTargetKind.individual;
  }

  @override
  void write(BinaryWriter writer, EventTargetKind obj) {
    writer.write(obj.index);
  }
}

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
    final targetData = Map<String, dynamic>.from(json['target'] as Map);
    final targetKind = _mapTargetKind(targetData['kind'] as String?);
    final targetUserId = targetData['user_id'] as String?;
    final targetTeamName = targetData['team_name'] as String?;
    final targetMemberId = targetData['member_id'] as String?;

    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    final createdAt = createdAtRaw is String
        ? DateTime.parse(createdAtRaw)
        : (createdAtRaw is DateTime ? createdAtRaw : DateTime.now());

    final rawType = json['rule_type'] ?? json['type'];
    final eventType = rawType != null
        ? (rawType.toString().toLowerCase() == 'bonus'
            ? RuleType.bonus
            : RuleType.malus)
        : (_extractPointsValue(json['points']) >= 0
            ? RuleType.bonus
            : RuleType.malus);

    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: _extractPointsValue(json['points']),
      creatorId: (json['creator_id'] ?? json['creatorId']) as String,
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
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
      'rule_type': type.toString().split('.').last,
      'description': description,
      'target': {
        'kind': target.kind.name,
        'team_name': target.teamName,
        'user_id': target.userId,
        'member_id': target.memberId,
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
