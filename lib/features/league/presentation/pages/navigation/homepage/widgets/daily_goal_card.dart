import 'dart:ui';

import 'package:fantavacanze_official/core/constants/lock_type.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';

class DailyGoalCard extends StatefulWidget {
  final String name;
  final double score;
  final bool isLocked;
  final Color startColor;
  final Color endColor;
  final bool isRefreshed;
  final bool isCompleted;
  final VoidCallback? onRefresh;
  final VoidCallback? onComplete;
  final String challengeId;
  final LockType lockType;
  final VoidCallback? onLockedTap;

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
    this.onComplete,
    required this.challengeId,
    this.lockType = LockType.premium,
    this.onLockedTap,
  });

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard>
    with SingleTickerProviderStateMixin {
  // Animation controller for the swipe effect
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Threshold to trigger completion dialog
  final double _dismissThreshold = 0.3;

  // Track if dismissal is in progress
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return _buildLockedContent(context);
    }

    // If the card is already completed, show as completed
    if (widget.isCompleted) {
      return _buildCompletedCard(context);
    }

    // For active cards, use Dismissible for a modern swipe effect
    return Dismissible(
      key: Key('dismissible_${widget.challengeId}'),
      direction: DismissDirection.startToEnd, // Only allow right-to-left swipe
      dismissThresholds: {DismissDirection.startToEnd: _dismissThreshold},
      onUpdate: (details) {
        // Update animation progress based on dismiss progress
        _animationController.value = details.progress;
      },
      confirmDismiss: (direction) async {
        if (_isDismissing) return false;
        _isDismissing = true;

        // Show confirmation dialog
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => ConfirmationDialog.completeChallenge(
            challengeName: widget.name,
            onComplete: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              }
              return true;
            },
          ),
        );

        _isDismissing = false;
        return result ?? false;
      },
      background: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  ColorPalette.success.withValues(alpha: 0.9),
                  ColorPalette.success.withValues(alpha: 0.7),
                ],
                stops: [0.0, 0.7 + (_progressAnimation.value * 0.3)],
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.success.withValues(
                      alpha: 0.2 + (_progressAnimation.value * 0.2)),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white.withValues(
                          alpha: 0.4 + (_progressAnimation.value * 0.6)),
                      size: 24 + (_progressAnimation.value * 8),
                    ),
                    const SizedBox(width: 8),
                    AnimatedOpacity(
                      opacity: _progressAnimation.value > 0.7 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text(
                        'Completa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.startColor, widget.endColor],
          ),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: widget.endColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: _buildUnlockedContent(context),
        ),
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.lg, vertical: ThemeSizes.sm),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.startColor, widget.endColor],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: widget.endColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        child: Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),

            // Content with completion indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md,
                vertical: ThemeSizes.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white,
                        decorationThickness: 2.0,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusSm),
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
                          "${widget.score}",
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
            ),
          ],
        ),
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
          // Mostra il pulsante di refresh SOLO se:
          // - la card non è bloccata
          // - non è completata
          // - non è già stata refreshata
          // - è presente il callback onRefresh
          if (!widget.isLocked &&
              !widget.isCompleted &&
              !widget.isRefreshed &&
              widget.onRefresh != null)
            _buildRefreshButton(context),

          const SizedBox(width: 5),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Nome della challenge
                Text(
                  widget.name,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: ColorPalette.white,
                    fontWeight: FontWeight.w600,
                    decoration: widget.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.white,
                    decorationThickness: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),

                // Se è completata, sovrapponi una linea bianca orizzontale
                if (widget.isCompleted)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.8),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  "${widget.score}",
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

  // Bottone di refresh in alto a sinistra
  Widget _buildRefreshButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: ThemeSizes.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onRefresh,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
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
    return GestureDetector(
      onTap: widget.onLockedTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.9,
                  ),
                ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.startColor.withValues(alpha: 0.8),
                        widget.endColor.withValues(alpha: 0.8)
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: widget.endColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Blurred
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.md,
                      vertical: ThemeSizes.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: Colors.white.withValues(alpha: 0.4),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.score}",
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Lock overlay centered - Change text based on lock type
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.md,
                      vertical: ThemeSizes.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.lockType == LockType.ads
                              ? Icons.ondemand_video
                              : Icons.lock_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.lockType == LockType.ads
                              ? "Sblocca"
                              : "Premium",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
