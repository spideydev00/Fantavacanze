import 'package:fantavacanze_official/features/league/data/models/event_model/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:hive/hive.dart';

part 'league_model.g.dart';

@HiveType(typeId: 4)
class LeagueModel extends League {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  String? get description => super.description;

  @HiveField(3)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(4)
  @override
  List<Participant> get participants => super.participants;

  @HiveField(5)
  @override
  List<Event> get events => super.events;

  @HiveField(6)
  @override
  List<Memory> get memories => super.memories;

  @HiveField(7)
  @override
  List<Rule> get rules => super.rules;

  @HiveField(8)
  @override
  List<String> get admins => super.admins;

  @HiveField(9)
  @override
  String get inviteCode => super.inviteCode;

  @HiveField(10)
  @override
  LeagueType get type => super.type;

  const LeagueModel({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
    required super.participants,
    required super.events,
    required super.memories,
    required super.rules,
    required super.admins,
    required super.inviteCode,
    required super.type,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    // Gestisci entrambi i formati: camelCase e snake_case
    final String inviteCode =
        (json['inviteCode'] ?? json['invite_code']) as String;
    final dynamic createdAtRaw = json['createdAt'] ?? json['created_at'];
    final String createdAtStr = createdAtRaw is String
        ? createdAtRaw
        : (createdAtRaw as DateTime).toIso8601String();
    final dynamic rawType =
        json['type'] ?? json['leagueType'] ?? json['league_type'];
    final dynamic rawIsTeamBased = json['isTeamBased'] ?? json['is_team_based'];
    LeagueType leagueType;
    if (rawType is String) {
      leagueType = rawType.toLowerCase() == 'team'
          ? LeagueType.team
          : LeagueType.individual;
    } else if (rawType is bool) {
      leagueType = rawType ? LeagueType.team : LeagueType.individual;
    } else if (rawIsTeamBased is bool) {
      leagueType = rawIsTeamBased ? LeagueType.team : LeagueType.individual;
    } else {
      leagueType = LeagueType.individual;
    }

    return LeagueModel(
      id: json['id'] as String,
      admins: List<String>.from(json['admins']),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(createdAtStr),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => RuleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      memories: (json['memories'] as List<dynamic>)
          .map((e) => MemoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: leagueType,
      inviteCode: inviteCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admins': admins,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'rules': rules.map((rule) => (rule as RuleModel).toJson()).toList(),
      'participants': participants
          .map((participant) => (participant as ParticipantModel).toJson())
          .toList(),
      'events': events.map((event) => (event as EventModel).toJson()).toList(),
      'memories':
          memories.map((memory) => (memory as MemoryModel).toJson()).toList(),
      'type': type.name,
      'invite_code': inviteCode,
    };
  }

  LeagueModel copyWith({
    String? id,
    List<String>? admins,
    String? name,
    String? description,
    DateTime? createdAt,
    List<Rule>? rules,
    List<Participant>? participants,
    List<Event>? events,
    List<Memory>? memories,
    LeagueType? type,
    String? inviteCode,
  }) {
    return LeagueModel(
      id: id ?? this.id,
      admins: admins ?? this.admins,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rules: rules ?? this.rules,
      participants: participants ?? this.participants,
      events: events ?? this.events,
      memories: memories ?? this.memories,
      type: type ?? this.type,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
