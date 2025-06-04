import 'package:fantavacanze_official/features/league/data/models/individual_participant_model/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model/team_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

/// Utility class for resolving participant names from events and IDs
class ParticipantNameResolver {
  /// Resolves a participant name from an event's targetUser
  static String resolveParticipantName(Event event, League league) {
    // Handle team member events
    if (event.isTeamMember) {
      for (final participant in league.participants) {
        if (participant is TeamParticipantModel) {
          for (final member in participant.members) {
            if (member.userId == event.targetUser) {
              return "${member.name} (${participant.name})";
            }
          }
        }
      }
    }
    // Handle team events (where targetUser is the team name)
    else if (league.isTeamBased) {
      // First check if it matches any team name directly
      for (final participant in league.participants) {
        if (participant.name == event.targetUser) {
          return participant.name;
        }
      }
    }
    // Handle individual events
    else {
      for (final participant in league.participants) {
        if (participant is IndividualParticipantModel &&
            participant.userId == event.targetUser) {
          return participant.name;
        }
      }
    }

    // Fallback if we couldn't find a match
    return event.targetUser;
  }
}
