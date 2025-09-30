import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_participant.dart';
import 'package:flutter/material.dart';

/// Widget per visualizzare un singolo partecipante nella classifica Fantaserata
class FsLeaderboardItem extends StatelessWidget {
  final FsParticipant participant;
  final int position;

  const FsLeaderboardItem({
    super.key,
    required this.participant,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    // Medal colors for top 3 positions
    final medalColors = {
      1: Colors.amber, // Gold
      2: Colors.grey.shade400, // Silver
      3: Colors.brown.shade300, // Bronze
    };

    final medalColor = medalColors[position];

    final points = NumberFormatter.formatPoints(participant.points);
    final bonusTotal = NumberFormatter.formatPoints(participant.bonusTotal);
    final malusTotal = NumberFormatter.formatPoints(participant.malusTotal);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.sm,
        horizontal: ThemeSizes.md,
      ),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
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
                    '$position',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
          ),

          const SizedBox(width: 6),

          // Participant name
          Expanded(
            flex: 4,
            child: Text(
              participant.name,
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
              bonusTotal,
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
              malusTotal,
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
              points,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
