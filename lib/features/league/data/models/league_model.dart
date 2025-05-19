import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

class LeagueModel extends League {
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
    required super.inviteCode, // Now required
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    // Get inviteCode from either inviteCode or invite_code field in JSON
    final String inviteCode =
        (json['inviteCode'] ?? json['invite_code']) as String;

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
      inviteCode: inviteCode,
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
    bool? isTeamBased,
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
      isTeamBased: isTeamBased ?? this.isTeamBased,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
