import 'package:fantavacanze_official/core/utils/participant_name_resolver.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/core/utils/event_finder.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/event_card.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class EventsListWidget extends StatelessWidget {
  /// The league containing the events
  final League league;

  /// Optional participant to filter events for
  final Participant? participant;

  /// Maximum number of events to display (null for unlimited)
  final int? limit;

  /// Callback when an event is tapped
  final Function(Event event)? onEventTap;

  /// Optional title for the list
  final String? title;

  /// Whether to show all events or just for one participant
  final bool showAllEvents;

  /// Padding to apply to the entire widget
  final EdgeInsets padding;

  const EventsListWidget({
    super.key,
    required this.league,
    this.participant,
    this.limit,
    this.onEventTap,
    this.title,
    this.showAllEvents = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    // Get events based on whether we're showing all or filtered
    final List<Event> events =
        showAllEvents ? _getAllEvents() : _getFilteredEvents();

    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    // Limit the number of events if specified
    final displayEvents = limit != null && events.length > limit!
        ? events.sublist(0, limit!)
        : events;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...displayEvents.map((event) {
            // Pre-resolve the participant name for display
            String resolvedName =
                ParticipantNameResolver.resolveParticipantName(event, league);

            // Create a modified event with the resolved name
            final displayEvent = _EventWithResolvedName(
              originalEvent: event,
              resolvedName: resolvedName,
            );

            return EventCard(
              event: displayEvent,
              onTap: onEventTap != null ? () => onEventTap!(event) : null,
              showDetails: true,
            );
          }),
        ],
      ),
    );
  }

  List<Event> _getAllEvents() {
    // Return all events, sorted by date
    final allEvents = List<Event>.from(league.events);
    allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allEvents;
  }

  List<Event> _getFilteredEvents() {
    if (participant == null) {
      return [];
    }

    return EventFinder.getAllEventsForParticipant(
      league: league,
      participant: participant!,
      isTeamBased: league.isTeamBased,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy_outlined,
      title: 'Nessun evento trovato',
      subtitle: 'Gli eventi appariranno qui quando verranno aggiunti',
    );
  }
}

/// Private class to wrap an event with a resolved participant name
/// This allows us to reuse the existing EventCard without modification
class _EventWithResolvedName implements Event {
  final Event originalEvent;
  final String resolvedName;

  _EventWithResolvedName({
    required this.originalEvent,
    required this.resolvedName,
  });

  // Forward all properties from the original event
  @override
  String get id => originalEvent.id;

  @override
  String get name => originalEvent.name;

  @override
  double get points => originalEvent.points;

  @override
  String get creatorId => originalEvent.creatorId;

  // Replace targetUser with our resolved name for display
  @override
  String get targetUser => resolvedName;

  @override
  DateTime get createdAt => originalEvent.createdAt;

  @override
  RuleType get type => originalEvent.type;

  @override
  String? get description => originalEvent.description;

  @override
  bool get isTeamMember => originalEvent.isTeamMember;
}
