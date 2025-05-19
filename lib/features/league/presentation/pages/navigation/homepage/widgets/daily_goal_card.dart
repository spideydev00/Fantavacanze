import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class DailyGoalCard extends StatelessWidget {
  final String name;
  final int score;
  final bool isLocked;
  final Color startColor;
  final Color endColor;

  const DailyGoalCard({
    super.key,
    required this.name,
    required this.score,
    this.isLocked = false,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    // Single container approach with decorations applied based on locked state
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: endColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: isLocked
            ? _buildLockedContent(context)
            : _buildUnlockedContent(context),
      ),
    );
  }

  Widget _buildUnlockedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleSmall?.copyWith(
                color: ColorPalette.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                shadows: [
                  Shadow(
                    blurRadius: 3,
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: ThemeSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "$score pts",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      child: Stack(
        children: [
          // Show faded background content
          Opacity(
            opacity: 0.3,
            child: _buildUnlockedContent(context),
          ),
          // Show premium overlay with proper centering
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Premium",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
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
}
