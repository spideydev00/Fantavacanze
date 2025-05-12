import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/leaderboard/leaderboard_header.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/leaderboard/leaderboard_item.dart';
import 'package:flutter/material.dart';

/// A complete leaderboard widget that displays participants in ranked order.
/// Combines LeaderboardHeader and LeaderboardItem widgets.
class LeaderboardList extends StatelessWidget {
  /// The league to display the leaderboard for
  final League league;

  /// Optional custom header widget
  final Widget? customHeader;

  /// Optional custom builder for individual leaderboard items
  final Widget Function(BuildContext, Participant, int, bool, League)?
      itemBuilder;

  /// Optional padding for the entire list
  final EdgeInsets? padding;

  /// Custom empty state widget when there are no participants
  final Widget? emptyStateWidget;

  /// Controls how to sort participants
  final List<Participant> Function(List<Participant>)? sortParticipants;

  const LeaderboardList({
    super.key,
    required this.league,
    this.customHeader,
    this.itemBuilder,
    this.padding,
    this.emptyStateWidget,
    this.sortParticipants,
  });

  @override
  Widget build(BuildContext context) {
    // Sort participants (default is by points in descending order)
    final sortedParticipants = sortParticipants != null
        ? sortParticipants!(List<Participant>.from(league.participants))
        : _getSortedParticipants(league);

    // Handle empty state
    if (sortedParticipants.isEmpty) {
      return emptyStateWidget ??
          Center(
            child: Text(
              'Nessun partecipante trovato',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        itemCount: sortedParticipants.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header
            return customHeader ??
                LeaderboardHeader(isTeamBased: league.isTeamBased);
          } else {
            // List items
            final participant = sortedParticipants[index - 1];
            final position = index;

            // Use custom item builder if provided
            if (itemBuilder != null) {
              return itemBuilder!(
                  context, participant, position, league.isTeamBased, league);
            }

            // Default item
            return LeaderboardItem(
              participant: participant,
              position: position,
              isTeamBased: league.isTeamBased,
              league: league,
            );
          }
        },
      ),
    );
  }

  /// Default sort method - by points in descending order
  List<Participant> _getSortedParticipants(League league) {
    final participants = List<Participant>.from(league.participants);

    // Sort by points in descending order
    participants.sort((a, b) => b.points.compareTo(a.points));

    return participants;
  }
}
