import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

/// A header component for rule dialogs
///
/// This component displays a consistent header for rule dialogs,
/// with an icon, title, and optional close button.
class RuleDialogHeader extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The rule type (affects the icon color)
  final RuleType ruleType;

  /// Whether to show the close button
  final bool showCloseButton;

  /// Optional icon to override the default
  final IconData? icon;

  /// Optional callback when close button is pressed
  final VoidCallback? onClose;

  const RuleDialogHeader({
    super.key,
    required this.title,
    required this.ruleType,
    this.showCloseButton = true,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        ruleType == RuleType.bonus ? ColorPalette.success : ColorPalette.error;
    final defaultIcon =
        ruleType == RuleType.bonus ? Icons.add_circle : Icons.remove_circle;

    return Row(
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(ThemeSizes.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? defaultIcon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: ThemeSizes.sm),

        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),

        // Optional close button
        if (showCloseButton)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
