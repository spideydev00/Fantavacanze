import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';

/// Utility class for resolving participant names from events and IDs
class ParticipantNameResolver {
  /// Resolves a participant name from an event target
  static String resolveParticipantName(Event event, League league) {
    switch (event.target.kind) {
      case EventTargetKind.teamMember:
        for (final participant in league.participants) {
          if (participant is TeamParticipant) {
            for (final member in participant.members) {
              if (member.userId ==
                  (event.target.memberId ?? event.target.userId)) {
                return "${member.name} (${participant.name})";
              }
            }
          }
        }
        break;
      case EventTargetKind.team:
        for (final participant in league.participants) {
          if (participant is TeamParticipant &&
              participant.name == event.target.teamName) {
            return participant.name;
          }
        }
        break;
      case EventTargetKind.individual:
        for (final participant in league.participants) {
          if (participant is IndividualParticipant &&
              participant.userId == event.target.userId) {
            return participant.name;
          }
        }
        break;
    }

    // Fallback to whatever identifier is present
    return event.target.memberId ??
        event.target.userId ??
        event.target.teamName ??
        '';
  }
}
