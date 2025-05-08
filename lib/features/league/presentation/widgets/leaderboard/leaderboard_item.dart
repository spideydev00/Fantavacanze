import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/date_formatter.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/core/utils/event_finder.dart';
import 'package:flutter/material.dart';

/// A flexible component that displays a participant item in a leaderboard
/// with expandable details showing the last event
class LeaderboardItem extends StatefulWidget {
  /// The participant to display in the leaderboard
  final Participant participant;

  /// The position/rank of the participant in the leaderboard
  final int position;

  /// Whether the league is team-based or individual-based
  final bool isTeamBased;

  /// The league which this participant belongs to, needed to find events
  final League league;

  /// Optional custom widget to display in the expanded section
  final Widget? expandedContent;

  /// Optional callback for when the expand/collapse button is pressed
  final Function(bool isExpanded)? onToggleExpanded;

  /// Optional styling for medal colors based on position
  final Map<int, Color>? medalColors;

  /// Optional custom builder for rendering the last event
  final Widget Function(BuildContext context, Event event)? lastEventBuilder;

  const LeaderboardItem({
    super.key,
    required this.participant,
    required this.position,
    required this.isTeamBased,
    required this.league,
    this.expandedContent,
    this.onToggleExpanded,
    this.medalColors,
    this.lastEventBuilder,
  });

  @override
  State<LeaderboardItem> createState() => _LeaderboardItemState();
}

class _LeaderboardItemState extends State<LeaderboardItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Default medal colors
    final defaultMedalColors = {
      1: Colors.amber, // Gold
      2: Colors.grey.shade400, // Silver
      3: Colors.brown.shade300, // Bronze
    };

    // Use provided medal colors or fall back to defaults
    final medalColors = widget.medalColors ?? defaultMedalColors;
    final medalColor = medalColors[widget.position];

    // Find the last event for this participant using utility class
    final lastEvent = EventFinder.findLastEventForParticipant(
      league: widget.league,
      participant: widget.participant,
      isTeamBased: widget.isTeamBased,
    );

    return Column(
      children: [
        // Main participant row
        Container(
          margin: EdgeInsets.only(bottom: _isExpanded ? 0 : ThemeSizes.xs),
          padding: const EdgeInsets.symmetric(
              vertical: ThemeSizes.sm, horizontal: ThemeSizes.md),
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(ThemeSizes.borderRadiusMd),
              topRight: const Radius.circular(ThemeSizes.borderRadiusMd),
              bottomLeft:
                  Radius.circular(_isExpanded ? 0 : ThemeSizes.borderRadiusMd),
              bottomRight:
                  Radius.circular(_isExpanded ? 0 : ThemeSizes.borderRadiusMd),
            ),
            boxShadow: [
              BoxShadow(
                color: context.textSecondaryColor.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Position or medal
              SizedBox(
                width: 28,
                child: medalColor != null
                    ? Icon(
                        Icons.emoji_events,
                        color: medalColor,
                        size: 24,
                      )
                    : Text(
                        '${widget.position}',
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
              ),

              SizedBox(width: 6),

              // Participant name
              Expanded(
                flex: 4,
                child: Text(
                  widget.participant.name,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

              // Bonus points
              Expanded(
                flex: 2,
                child: Text(
                  '${widget.participant.bonusTotal}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: ColorPalette.success,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Malus points
              Expanded(
                flex: 2,
                child: Text(
                  '${widget.participant.malusTotal}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: ColorPalette.error,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Total points
              Expanded(
                flex: 2,
                child: Text(
                  '${widget.participant.points.toInt()}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Expand/collapse button
              SizedBox(
                width: 32,
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 18,
                    color: context.textSecondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });

                    if (widget.onToggleExpanded != null) {
                      widget.onToggleExpanded!(_isExpanded);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Expanded details section
        if (_isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md, vertical: ThemeSizes.sm),
            margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
            decoration: BoxDecoration(
              color: context.secondaryBgColor.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(ThemeSizes.borderRadiusMd),
                bottomRight: Radius.circular(ThemeSizes.borderRadiusMd),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.textSecondaryColor.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: widget.expandedContent ?? _buildLastEventContent(lastEvent),
          ),
      ],
    );
  }

  Widget _buildLastEventContent(Event? lastEvent) {
    if (lastEvent == null) {
      return Row(
        children: [
          Icon(
            Icons.event_busy,
            size: 16,
            color: context.textSecondaryColor,
          ),
          const SizedBox(width: ThemeSizes.xs),
          Text(
            "Nessun evento recente",
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      );
    }

    // If a custom builder is provided, use it
    if (widget.lastEventBuilder != null) {
      return widget.lastEventBuilder!(context, lastEvent);
    }

    final bool isPositive = lastEvent.points >= 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
          size: 16,
          color: isPositive ? ColorPalette.success : ColorPalette.error,
        ),
        const SizedBox(width: ThemeSizes.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lastEvent.name,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.textPrimaryColor,
                ),
              ),
              if (lastEvent.description != null &&
                  lastEvent.description!.isNotEmpty)
                Text(
                  lastEvent.description!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              Text(
                "${isPositive ? '+' : ''}${lastEvent.points} punti • ${DateFormatter.formatRelativeTime(lastEvent.createdAt)}",
                style: context.textTheme.bodySmall?.copyWith(
                  color: isPositive ? ColorPalette.success : ColorPalette.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
