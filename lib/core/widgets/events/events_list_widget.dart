import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/in-game/participant_name_resolver.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/core/utils/in-game/event_finder.dart';
import 'package:fantavacanze_official/core/widgets/events/event_card.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class EventsListWidget extends StatefulWidget {
  /// The league containing the events
  final League league;

  /// Optional participant to filter events for
  final Participant? participant;

  /// Callback when an event is tapped
  final Function(Event event)? onEventTap;

  /// Optional title for the list
  final String? title;

  /// Whether to show all events or just for one participant
  final bool showAllEvents;

  /// Padding to apply to the entire widget
  final EdgeInsets padding;

  /// Whether to allow dismissing of events
  final bool allowDismiss;

  /// Callback when an event is dismissed
  final Function(Event event)? onEventDismiss;

  const EventsListWidget({
    super.key,
    required this.league,
    this.participant,
    this.onEventTap,
    this.title,
    this.showAllEvents = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.allowDismiss = false,
    this.onEventDismiss,
  });

  @override
  State<EventsListWidget> createState() => _EventsListWidgetState();
}

class _EventsListWidgetState extends State<EventsListWidget> {
  static const int _pageSize = 5;
  int _currentlyShownEvents = _pageSize;

  @override
  Widget build(BuildContext context) {
    // Get events based on whether we're showing all or filtered
    final List<Event> allEvents =
        widget.showAllEvents ? _getAllEvents() : _getFilteredEvents();

    if (allEvents.isEmpty) {
      return _buildEmptyState(context);
    }

    // Determine how many events to show
    final int eventsToShow = _currentlyShownEvents > allEvents.length
        ? allEvents.length
        : _currentlyShownEvents;

    final displayEvents = allEvents.sublist(0, eventsToShow);
    final bool hasMoreEvents = eventsToShow < allEvents.length;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Events list
          ...displayEvents.map((event) {
            // Pre-resolve the participant name for display
            String resolvedName =
                ParticipantNameResolver.resolveParticipantName(
                    event, widget.league);

            return EventCard(
              event: event,
              targetNameOverride: resolvedName,
              onTap: widget.onEventTap != null
                  ? () => widget.onEventTap!(event)
                  : null,
              showDetails: true,
              allowDismiss: widget.allowDismiss,
              onDismiss: widget.onEventDismiss != null
                  ? () {
                      widget.onEventDismiss!(event);
                    }
                  : null,
            );
          }),

          // Show more button
          if (hasMoreEvents)
            Padding(
              padding: const EdgeInsets.only(top: ThemeSizes.md),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentlyShownEvents += _pageSize;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.lg,
                      vertical: ThemeSizes.sm,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mostra altri',
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: ThemeSizes.xs),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: context.textPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Event> _getAllEvents() {
    // Return all events, sorted by date
    final allEvents = List<Event>.from(widget.league.events);
    allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allEvents;
  }

  List<Event> _getFilteredEvents() {
    if (widget.participant == null) {
      return [];
    }

    return EventFinder.getAllEventsForParticipant(
      league: widget.league,
      participant: widget.participant!,
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
