import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

/// A banner that displays information about rules
///
/// This component is used to display contextual information about
/// rule types (bonus or malus) with consistent styling.
class RuleInfoBanner extends StatelessWidget {
  /// The message to display in the banner
  final String message;

  /// The primary color for the banner (usually green for bonus, red for malus)
  final Color color;

  /// The icon to display (defaults to info_outline)
  final IconData icon;

  /// Optional padding
  final EdgeInsets? padding;

  /// Optional margin
  final EdgeInsets? margin;

  /// Optional icon size
  final double iconSize;

  /// Optional font size for the text
  final double fontSize;

  const RuleInfoBanner({
    super.key,
    required this.message,
    required this.color,
    this.icon = Icons.info_outline,
    this.padding,
    this.margin,
    this.iconSize = 18,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: ThemeSizes.md,
            vertical: ThemeSizes.sm,
          ),
      margin: margin ?? const EdgeInsets.only(bottom: ThemeSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: ThemeSizes.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: fontSize,
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
