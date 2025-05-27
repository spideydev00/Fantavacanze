import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class EventPreviewCard extends StatelessWidget {
  final String name;
  final double points;
  final String? description;
  final bool hasSelectedParticipant;

  const EventPreviewCard({
    super.key,
    required this.name,
    required this.points,
    this.description,
    this.hasSelectedParticipant = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if it's a bonus or malus based on the sign of points
    final bool isBonus = points >= 0;
    final mainColor = isBonus ? ColorPalette.success : ColorPalette.error;

    // Format points for display
    final String pointsDisplay;
    if (isBonus) {
      pointsDisplay = "+ ${points.abs()}";
    } else {
      pointsDisplay = "- ${points.abs()}";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.6),
            mainColor.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBonus ? Icons.add_circle : Icons.remove_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBonus ? 'Bonus' : 'Malus',
                        style: context.textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        name,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.md,
                    vertical: ThemeSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pointsDisplay, // Use formatted points with proper sign
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          // Content
          if (description != null && description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrizione',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.xs),
                  Text(
                    description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Assignment status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: ThemeSizes.sm,
              horizontal: ThemeSizes.md,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(ThemeSizes.borderRadiusMd),
                bottomRight: Radius.circular(ThemeSizes.borderRadiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasSelectedParticipant
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: ThemeSizes.xs),
                Text(
                  hasSelectedParticipant
                      ? 'Pronto per l\'assegnazione'
                      : 'Seleziona un partecipante',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
