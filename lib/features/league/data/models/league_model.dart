import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';

class LeagueModel extends League {
  final String? inviteCode;

  const LeagueModel({
    required super.id,
    required super.admins,
    required super.name,
    super.description,
    required super.createdAt,
    required super.rules,
    required super.participants,
    required super.events,
    required super.memories,
    required super.isTeamBased,
    this.inviteCode,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] as String,
      admins: List<String>.from(json['admins']),
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      isTeamBased: json['isTeamBased'] as bool,
      inviteCode:
          json['inviteCode'] as String? ?? json['invite_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admins': admins,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'rules': rules.map((rule) => (rule as RuleModel).toJson()).toList(),
      'participants': participants
          .map((participant) => (participant as ParticipantModel).toJson())
          .toList(),
      'events': events.map((event) => (event as EventModel).toJson()).toList(),
      'memories':
          memories.map((memory) => (memory as MemoryModel).toJson()).toList(),
      'isTeamBased': isTeamBased,
      'invite_code': inviteCode,
    };
  }
}
