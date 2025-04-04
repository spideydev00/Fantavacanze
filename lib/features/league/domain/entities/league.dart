import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

@immutable
class League {
  final String id;
  final List<String> admins;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<Rule> rules;
  final List<Participant> participants;
  final List<Event> events;
  final List<Memory> memories;
  final bool isTeamBased;

  const League({
    required this.id,
    required this.admins,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.rules,
    required this.participants,
    required this.events,
    required this.memories,
    required this.isTeamBased,
  });
}
