import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class DailyGoalCard extends StatelessWidget {
  final String name;
  final double score;
  final bool isLocked;
  final Color startColor;
  final Color endColor;
  final bool isRefreshed;
  final bool isCompleted;
  final VoidCallback? onRefresh;

  const DailyGoalCard({
    super.key,
    required this.name,
    required this.score,
    this.isLocked = false,
    required this.startColor,
    required this.endColor,
    this.isRefreshed = false,
    this.isCompleted = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
            color: endColor.withOpacity(0.3),
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
          // Only show refresh button if not refreshed, not completed, and onRefresh callback exists
          if (!isLocked && !isCompleted && !isRefreshed && onRefresh != null)
            _buildRefreshButton(context),

          SizedBox(width: 5),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Challenge name text
                Text(
                  name,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: ColorPalette.white,
                    fontWeight: FontWeight.w600,
                    // Apply line-through decoration if completed
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.white,
                    decorationThickness: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),

                // Alternative: horizontal line overlay for completed challenges
                if (isCompleted)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        height: 2,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: ThemeSizes.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "$score",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.2),
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

  // New method to build refresh button
  Widget _buildRefreshButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: ThemeSizes.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      child: Stack(
        children: [
          // First show the actual content (with blur effect)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: _buildUnlockedContent(context),
          ),

          // Then add the lock overlay on top
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
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
                            color: Colors.black.withOpacity(0.3),
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
