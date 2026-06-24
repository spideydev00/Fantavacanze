import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:hive/hive.dart';

part 'league.g.dart';

@HiveType(typeId: 18)
enum LeagueType {
  @HiveField(0)
  individual,

  @HiveField(1)
  team
}

@immutable
class League {
  final String id;
  final List<String> admins;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<Rule> rules;
  final List<Participant> participants;
  final List<Event> events;
  final List<Memory> memories;
  final LeagueType type;
  final String inviteCode;
  final String? partner;
  final String? partnerDestinationId;
  final String? partnerRoundId;

  const League({
    required this.id,
    required this.admins,
    required this.name,
    this.description,
    required this.createdAt,
    required this.rules,
    required this.participants,
    required this.events,
    required this.memories,
    required this.type,
    required this.inviteCode,
    this.partner,
    this.partnerDestinationId,
    this.partnerRoundId,
  });
}
