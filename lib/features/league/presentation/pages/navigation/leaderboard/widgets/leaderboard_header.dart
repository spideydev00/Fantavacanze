import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

/// A reusable header component for leaderboard displays.
/// Provides column headers for the leaderboard items.
class LeaderboardHeader extends StatelessWidget {
  /// Whether the league is team-based (determines the label for participants)
  final bool isTeamBased;

  /// Optional background gradient colors for the header
  final List<Color>? gradientColors;

  /// Optional custom labels for each column
  final String? participantLabel;
  final String? bonusLabel;
  final String? malusLabel;
  final String? pointsLabel;

  /// Flex values for the column widths
  final int participantFlex;
  final int statsFlex;

  /// Optional widget to display at the end of the header
  final Widget? trailingWidget;

  /// Optional margin for the header
  final EdgeInsets? margin;

  const LeaderboardHeader({
    super.key,
    required this.isTeamBased,
    this.gradientColors,
    this.participantLabel,
    this.bonusLabel,
    this.malusLabel,
    this.pointsLabel,
    this.participantFlex = 4,
    this.statsFlex = 2,
    this.trailingWidget,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Default gradient colors if none provided
    final defaultGradientColors = [
      context.primaryColor.withValues(alpha: 0.6),
      context.primaryColor,
      context.primaryColor,
      context.primaryColor,
      context.primaryColor,
      context.primaryColor,
      context.primaryColor.withValues(alpha: 0.6),
    ];

    // Use custom labels or defaults
    final pLabel = participantLabel ?? (isTeamBased ? 'Squadra' : 'Giocatore');
    final bLabel = bonusLabel ?? 'Bonus';
    final mLabel = malusLabel ?? 'Malus';
    final ptLabel = pointsLabel ?? 'Punti';

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.md,
      ),
      margin: margin ??
          const EdgeInsets.only(top: ThemeSizes.md, bottom: ThemeSizes.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? defaultGradientColors,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Participant icon
          SizedBox(
            width: 28,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.white.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.person_outline_rounded,
                color: ColorPalette.white,
                size: 16,
              ),
            ),
          ),

          SizedBox(width: ThemeSizes.xs),

          // Participant label
          Expanded(
            flex: participantFlex,
            child: Text(
              pLabel,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bonus label
          Expanded(
            flex: statsFlex,
            child: Text(
              bLabel,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: ColorPalette.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Malus label
          Expanded(
            flex: statsFlex,
            child: Text(
              mLabel,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Points label
          Expanded(
            flex: statsFlex,
            child: Text(
              ptLabel,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Optional trailing widget (e.g., info button)
          trailingWidget ?? const SizedBox(width: 32),
        ],
      ),
    );
  }
}
