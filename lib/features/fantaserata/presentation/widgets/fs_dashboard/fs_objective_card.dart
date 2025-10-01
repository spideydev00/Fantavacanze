import 'dart:ui';
import 'package:fantavacanze_official/core/constants/fantaserata/simple_fs_rule.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:flutter/material.dart';

class FsObjectiveCard extends StatelessWidget {
  final SimpleFsRule rule;
  final bool isCompleted;
  final bool isLocked;
  final bool canRefresh;
  final bool isDynamic;
  final int position;
  final VoidCallback? onRefresh;
  final VoidCallback? onComplete;
  final VoidCallback? onAdUnlock;
  final VoidCallback? onPremiumUnlock;

  const FsObjectiveCard({
    super.key,
    required this.rule,
    this.isCompleted = false,
    this.isLocked = false,
    this.canRefresh = false,
    this.isDynamic = false,
    required this.position,
    this.onRefresh,
    this.onComplete,
    this.onAdUnlock, // Nuovo callback per ads
    this.onPremiumUnlock, // Nuovo callback per premium
  });

  @override
  Widget build(BuildContext context) {
    final isBonus = rule.type == FsRuleType.bonus;
    final mainColor = _getMainColor(isBonus);

    if (isLocked) return _buildLockedCard(context, mainColor);
    if (isCompleted) return _buildCompletedCard(context, mainColor);
    return _buildActiveCard(context, mainColor, isBonus);
  }

  Color _getMainColor(bool isBonus) {
    if (isBonus) {
      return isDynamic
          ? ColorPalette.fsCardDarkGreen
          : ColorPalette.fsCardlightGreen;
    } else {
      return ColorPalette.error;
    }
  }

  Widget _buildActiveCard(BuildContext context, Color mainColor, bool isBonus) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.4),
            mainColor.withValues(alpha: 0.6),
            mainColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onComplete,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (canRefresh)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onRefresh,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
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
                            '${isBonus ? '+' : '-'}${rule.points.toStringAsFixed(rule.points == rule.points.toInt() ? 0 : 1)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(
                          ThemeSizes.borderRadiusSm,
                        ),
                      ),
                      child: Text(
                        isDynamic ? "Speciale" : "Standard",
                        style: context.textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Falcon Sport One",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeSizes.md),
                // Qui puoi tenere un limite se vuoi: maxLines: 3
                Text(
                  rule.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, Color mainColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.darkGrey.withValues(alpha: 0.5),
            ColorPalette.darkGrey.withValues(alpha: 0.7),
            ColorPalette.darkGrey,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.success.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Spacer(),
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
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rule.points.toStringAsFixed(rule.points == rule.points.toInt() ? 0 : 1)} pt',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            // Qui va bene troncare (è completata)
            Text(
              rule.name,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white,
                decorationThickness: 2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedCard(BuildContext context, Color mainColor) {
    return GestureDetector(
      onTap: () => _handleLockedTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mainColor.withValues(alpha: 0.4),
                        mainColor.withValues(alpha: 0.3),
                        mainColor.withValues(alpha: 0.2),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              Container(
                // solo minima, può crescere liberamente
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: position == 2
                                ? ColorPalette.warning // Colore diverso per ads
                                : ColorPalette.premiumUser,
                            borderRadius: BorderRadius.circular(
                              ThemeSizes.borderRadiusSm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                position == 2
                                    ? Icons.play_circle_outline // Icona ads
                                    : Icons.diamond_outlined, // Icona premium
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                position == 2 ? 'ADS' : 'PREMIUM',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      _getLockedCardText(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLockedTap(BuildContext context) {
    // Position 2 = ads unlock, Position 3 = premium only
    final isAdsUnlock = position == 2;
    final isPremiumOnly = position == 3;

    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PremiumAccessDialog(
        premiumOnly: isPremiumOnly,
        title: 'Obiettivo Bloccato',
        description: isPremiumOnly
            ? 'Questo obiettivo è disponibile solo per utenti premium!'
            : isAdsUnlock
                ? 'Scegli come sbloccare questo obiettivo:'
                : 'Sblocca questo obiettivo per guadagnare punti extra!',
        onAdsBtnTapped:
            isAdsUnlock ? () => AdHelper().showRewardedAd(context) : null,
      ),
    ).then((granted) {
      if (granted == true) {
        // Se è una card sbloccabile da ads
        if (isAdsUnlock && onAdUnlock != null) {
          onAdUnlock!();
        }
        // Se è una card premium
        else if (onPremiumUnlock != null) {
          onPremiumUnlock!();
        }
      }
    });
  }

  String _getLockedCardText() {
    switch (position) {
      case 2:
        return 'Obiettivo sbloccabile guardando una pubblicità o con premium.';
      case 3:
        return 'Obiettivo speciale disponibile solo per utenti premium.';
      default:
        return 'Obiettivo speciale disponibile per utenti premium.';
    }
  }
}
