import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/date_formatter.dart';
import 'package:fantavacanze_official/core/utils/event_finder.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:flutter/material.dart';

class EventsList extends StatelessWidget {
  final League league;
  final Participant participant;
  final bool isTeamBased;

  const EventsList({
    super.key,
    required this.league,
    required this.participant,
    required this.isTeamBased,
  });

  @override
  Widget build(BuildContext context) {
    // Get events for this participant using EventFinder
    final events = EventFinder.getAllEventsForParticipant(
      league: league,
      participant: participant,
      isTeamBased: isTeamBased,
    );

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: context.textSecondaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Nessun evento aggiunto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.xs),
              Text(
                'Gli eventi verranno visualizzati qui quando l\'admin ne aggiungerà',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Display most recent events (max 5)
    final recentEvents = events.take(5).toList();

    return Column(
      children: [
        ...recentEvents.map((event) => EventListItem(event: event)),
        if (events.length > 5)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to full events history page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Visualizzazione eventi completa da implementare'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Vedi tutti (${events.length})',
                style: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EventListItem extends StatelessWidget {
  final Event event;

  const EventListItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isBonus = event.points > 0;
    final color = isBonus ? ColorPalette.success : ColorPalette.error;
    final pointsText = isBonus ? '+${event.points}' : '${event.points}';
    final icon = isBonus ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      padding: const EdgeInsets.all(ThemeSizes.sm),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBonus ? 'Bonus' : 'Malus'}: ${event.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      pointsText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: context.textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelativeTime(event.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
