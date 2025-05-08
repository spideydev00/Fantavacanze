import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

class RuleItem extends StatelessWidget {
  final Rule rule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RuleItem({
    super.key,
    required this.rule,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBonus = rule.type == RuleType.bonus;
    final mainColor = isBonus ? ColorPalette.success : ColorPalette.error;

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        side: BorderSide(
          color: mainColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              mainColor.withValues(alpha: 0.2),
              mainColor.withValues(alpha: 0.15),
              mainColor.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ThemeSizes.xs,
            horizontal: ThemeSizes.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left status indicator
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusSm),
                ),
              ),
              const SizedBox(width: ThemeSizes.sm),

              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  border: Border.all(
                    color: mainColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${isBonus ? '+' : '-'}${rule.points.abs().toInt()}',
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: ThemeSizes.sm),

              // Rule name - modified to allow wrapping
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  child: Center(
                    child: Text(
                      rule.name,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      // Allow up to 2 lines
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),

              // Action buttons with a more subtle design
              if (onEdit != null || onDelete != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: context.textSecondaryColor,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: onEdit,
                        tooltip: 'Modifica',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: context.textSecondaryColor,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                        tooltip: 'Rimuovi',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
