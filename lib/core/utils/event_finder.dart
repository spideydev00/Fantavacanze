import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';

/// Utility functions for finding and filtering events in a league
class EventFinder {
  /// Finds the most recent event for a participant
  static Event? findLastEventForParticipant({
    required League league,
    required Participant participant,
    required bool isTeamBased,
  }) {
    // If there are no events
    if (league.events.isEmpty) {
      return null;
    }

    // Sort events by createdAt (most recent first)
    final sortedEvents = List.from(league.events)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (isTeamBased) {
      // For team-based leagues, we need to handle two cases:
      // 1. Events targeting the entire team (where targetUser is the team name)
      // 2. Events targeting specific team members (where targetUser is the member ID)
      for (final event in sortedEvents) {
        // Case 1: Direct team event
        if (!event.isTeamMember && event.targetUser == participant.name) {
          return event;
        }

        // Case 2: Team member event - check if the member belongs to this team
        if (event.isTeamMember &&
            participant is TeamParticipant &&
            _isEventForTeamMember(event, participant)) {
          return event;
        }
      }
      return null;
    } else {
      // For individual leagues: find event where targetUser matches participant ID
      final Map<String, dynamic> participantData =
          (participant as dynamic).toJson();
      final String userId = participantData['userId'];

      for (final event in sortedEvents) {
        if (event.targetUser == userId) {
          return event;
        }
      }
      return null;
    }
  }

  /// Gets all events for a participant
  static List<Event> getAllEventsForParticipant({
    required League league,
    required Participant participant,
    required bool isTeamBased,
  }) {
    if (league.events.isEmpty) {
      return [];
    }

    final List<Event> participantEvents = [];

    if (isTeamBased) {
      // For team-based leagues, collect both direct team events and team member events
      for (final event in league.events) {
        // Direct team event
        if (!event.isTeamMember && event.targetUser == participant.name) {
          participantEvents.add(event);
        }

        // Team member event
        if (event.isTeamMember &&
            participant is TeamParticipant &&
            _isEventForTeamMember(event, participant)) {
          participantEvents.add(event);
        }
      }
    } else {
      // For individual leagues: find events where targetUser matches participant ID
      final Map<String, dynamic> participantData =
          (participant as dynamic).toJson();
      final String userId = participantData['userId'];

      for (final event in league.events) {
        if (event.targetUser == userId) {
          participantEvents.add(event);
        }
      }
    }

    // Sort by date (newest first)
    participantEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return participantEvents;
  }

  /// Helper method to check if an event is for a member of this team
  static bool _isEventForTeamMember(Event event, TeamParticipant team) {
    return team.members.any((member) => member.userId == event.targetUser);
  }
}
