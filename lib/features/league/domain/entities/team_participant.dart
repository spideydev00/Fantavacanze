import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/simple_participant.dart';

@immutable
class TeamParticipant extends Participant {
  final List<SimpleParticipant> members;
  final String? teamLogoUrl;
  final String captainId;

  const TeamParticipant({
    required this.members,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
    required this.captainId,
    this.teamLogoUrl,
  });

  // Helper method to extract just the userIds
  List<String> get userIds => members.map((member) => member.userId).toList();

  // Helper method to find a member by userId
  SimpleParticipant? findMemberById(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (_) {
      return null;
    }
  }

  // Helper method to get a member's name by userId
  String? getMemberNameById(String userId) {
    final member = findMemberById(userId);
    return member?.name;
  }
}
