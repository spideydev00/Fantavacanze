import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';

class SelectedRuleCard extends StatelessWidget {
  final Rule rule;
  final VoidCallback onClear;
  final EdgeInsetsGeometry margin;

  const SelectedRuleCard({
    super.key,
    required this.rule,
    required this.onClear,
    this.margin = const EdgeInsets.only(bottom: ThemeSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    final isBonus = rule.type == RuleType.bonus;
    final mainColor = isBonus ? ColorPalette.success : ColorPalette.error;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.2),
            mainColor.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Row(
          children: [
            // Rule icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBonus
                        ? Icons.add_circle_rounded
                        : Icons.remove_circle_rounded,
                    color: mainColor,
                    size: 32,
                  ),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '${isBonus ? "+" : "-"}${rule.points.abs()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: ThemeSizes.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isBonus
                              ? ColorPalette.success.withValues(alpha: 0.1)
                              : ColorPalette.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isBonus ? 'BONUS' : 'MALUS',
                          style: TextStyle(
                            color: mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Fix: Make the text use only available space
                      Flexible(
                        child: Text(
                          'Regola selezionata',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rule.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Clear selection button
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 20),
              splashRadius: 20,
              tooltip: 'Deseleziona regola',
            ),
          ],
        ),
      ),
    );
  }
}
