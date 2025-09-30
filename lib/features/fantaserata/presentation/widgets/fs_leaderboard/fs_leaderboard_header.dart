import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

/// Header component specifico per la classifica Fantaserata
class FsLeaderboardHeader extends StatelessWidget {
  const FsLeaderboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.md,
      ),
      margin: const EdgeInsets.only(top: ThemeSizes.md, bottom: ThemeSizes.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorPalette.fsGradients,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.fsGradients.first.withValues(alpha: 0.3),
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

          const SizedBox(width: ThemeSizes.xs),

          // Participant label
          Expanded(
            flex: 4,
            child: Text(
              'Giocatore',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bonus label
          Expanded(
            flex: 2,
            child: Text(
              'Bonus',
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
            flex: 2,
            child: Text(
              'Malus',
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
            flex: 2,
            child: Text(
              'Punti',
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
