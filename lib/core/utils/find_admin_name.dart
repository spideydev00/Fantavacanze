import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';

String findAdminName(League league, String adminId) {
  String adminName = '';
  // Search for admin in participants
  for (final participant in league.participants) {
    if (league.isTeamBased) {
      // For team-based leagues
      if (participant is TeamParticipant) {
        for (final member in participant.members) {
          if (member.userId == adminId) {
            adminName = member.name;
            break;
          }
        }
      }
    } else {
      // For individual leagues
      if (participant is IndividualParticipant &&
          participant.userId == adminId) {
        adminName = participant.name;
        break;
      }
    }
  }

  return adminName;
}
