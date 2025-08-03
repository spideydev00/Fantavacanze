import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';

/// Utility class for finding event data related to memories
class FindEventFromMemory {
  /// Finds an event by its ID from a league's events list
  /// Returns null if no matching event is found
  static Event? findEventById(String eventId, League league) {
    try {
      return league.events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  /// Finds the related event for a given memory within a specific league
  /// Returns null if memory has no relatedEventId or if event is not found
  static Event? findRelatedEvent(Memory memory, League league) {
    if (memory.relatedEventId == null) {
      return null;
    }

    return findEventById(memory.relatedEventId!, league);
  }

  /// Finds the related event for a given memory using AppLeagueCubit
  /// Returns null if no league is selected or event is not found
  static Event? findRelatedEventFromCubit(Memory memory, AppLeagueCubit cubit) {
    final state = cubit.state;
    if (state is! AppLeagueExists) {
      return null;
    }

    return findRelatedEvent(memory, state.selectedLeague);
  }

  /// Checks if a memory has a related event that exists in the league
  static bool hasValidRelatedEvent(Memory memory, League league) {
    return findRelatedEvent(memory, league) != null;
  }

  /// Checks if a memory has a related event using AppLeagueCubit
  static bool hasValidRelatedEventFromCubit(
      Memory memory, AppLeagueCubit cubit) {
    return findRelatedEventFromCubit(memory, cubit) != null;
  }

  /// Gets the event name from a memory, prioritizing the stored eventName
  /// Falls back to finding the event in the league if eventName is null
  static String? getEventName(Memory memory, League league) {
    // First try to use the cached event name from memory
    if (memory.eventName != null && memory.eventName!.isNotEmpty) {
      return memory.eventName;
    }

    // If no cached name, try to find the event in the league
    final relatedEvent = findRelatedEvent(memory, league);
    return relatedEvent?.name;
  }

  /// Gets the event name from a memory using AppLeagueCubit
  static String? getEventNameFromCubit(Memory memory, AppLeagueCubit cubit) {
    final state = cubit.state;
    if (state is! AppLeagueExists) {
      return memory.eventName;
    }

    return getEventName(memory, state.selectedLeague);
  }

  /// Gets complete event data for a memory from a league
  static Map<String, dynamic>? getEventData(Memory memory, League league) {
    final relatedEvent = findRelatedEvent(memory, league);

    if (relatedEvent == null && memory.eventName == null) {
      return null;
    }

    return {
      'id': memory.relatedEventId,
      'name': memory.eventName ?? relatedEvent?.name,
      'points': relatedEvent?.points,
      'creatorId': relatedEvent?.creatorId,
      'targetUser': relatedEvent?.targetUser,
      'createdAt': relatedEvent?.createdAt,
      'type': relatedEvent?.type,
      'description': relatedEvent?.description,
      'isTeamMember': relatedEvent?.isTeamMember,
    };
  }

  /// Gets complete event data for a memory using AppLeagueCubit
  static Map<String, dynamic>? getEventDataFromCubit(
      Memory memory, AppLeagueCubit cubit) {
    final state = cubit.state;
    if (state is! AppLeagueExists) {
      // Return minimal data if no league is available
      if (memory.eventName != null || memory.relatedEventId != null) {
        return {
          'id': memory.relatedEventId,
          'name': memory.eventName,
          'points': null,
          'creatorId': null,
          'targetUser': null,
          'createdAt': null,
          'type': null,
          'description': null,
          'isTeamMember': null,
        };
      }
      return null;
    }

    return getEventData(memory, state.selectedLeague);
  }

  /// Gets all memories related to a specific event from a league
  static List<Memory> getMemoriesForEvent(String eventId, League league) {
    return league.memories
        .where((memory) => memory.relatedEventId == eventId)
        .toList();
  }

  /// Gets all memories related to a specific event using AppLeagueCubit
  static List<Memory> getMemoriesForEventFromCubit(
      String eventId, AppLeagueCubit cubit) {
    final state = cubit.state;
    if (state is! AppLeagueExists) {
      return [];
    }

    return getMemoriesForEvent(eventId, state.selectedLeague);
  }
}
