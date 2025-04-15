import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists && state.selectedLeague != null) {
          final league = state.selectedLeague!;
          final sortedParticipants = _getSortedParticipants(league);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Classifica'),
            ),
            body: Column(
              children: [
                _LeaderboardHeader(isTeamBased: league.isTeamBased),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
                    itemCount: sortedParticipants.length,
                    itemBuilder: (context, index) {
                      return _LeaderboardItem(
                        participant: sortedParticipants[index],
                        position: index + 1,
                        isTeamBased: league.isTeamBased,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Nessuna lega selezionata'));
      },
    );
  }

  List<Participant> _getSortedParticipants(League league) {
    final participants = List<Participant>.from(league.participants);

    // Sort by points in descending order
    participants.sort((a, b) => b.points.compareTo(a.points));

    return participants;
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final bool isTeamBased;

  const _LeaderboardHeader({required this.isTeamBased});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.lg,
      ),
      margin: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 30), // Space for position
          Expanded(
            flex: 3,
            child: Text(
              isTeamBased ? 'Squadra' : 'Giocatore',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Bonus',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Malus',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Punti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final Participant participant;
  final int position;
  final bool isTeamBased;

  const _LeaderboardItem({
    required this.participant,
    required this.position,
    required this.isTeamBased,
  });

  @override
  Widget build(BuildContext context) {
    // Medal colors for top 3 positions
    Color? medalColor;
    if (position == 1) medalColor = Colors.amber;
    if (position == 2) medalColor = Colors.grey.shade400;
    if (position == 3) medalColor = Colors.brown.shade300;

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.md,
          horizontal: ThemeSizes.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: medalColor != null
                  ? Icon(
                      Icons.emoji_events,
                      color: medalColor,
                    )
                  : Text(
                      '$position.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textSecondaryColor,
                      ),
                    ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  if (isTeamBased)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: context.secondaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group,
                        size: 16,
                        color: context.primaryColor,
                      ),
                    )
                  else
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: context.secondaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: context.primaryColor,
                      ),
                    ),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      participant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '+${participant.bonusTotal}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '-${participant.malusTotal}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${participant.points.toInt()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
