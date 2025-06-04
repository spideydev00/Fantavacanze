import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

/// A component that provides standard action buttons for rule dialogs
///
/// This component displays cancel and save/confirm buttons with
/// consistent styling for rule creation/editing dialogs.
class RuleActionButtons extends StatelessWidget {
  /// The text for the primary action button (usually "Salva")
  final String primaryText;

  /// The text for the secondary action button (usually "Annulla")
  final String secondaryText;

  /// The rule type (affects the primary button color)
  final RuleType ruleType;

  /// Callback when the primary button is pressed
  final VoidCallback onPrimaryPressed;

  /// Optional callback when the secondary button is pressed
  final VoidCallback? onSecondaryPressed;

  /// Optional icons for the buttons
  final IconData? primaryIcon;
  final IconData? secondaryIcon;

  /// Optional width for the primary button
  final double? primaryButtonWidth;

  /// Whether the buttons should be displayed in reverse order
  final bool reverseOrder;

  const RuleActionButtons({
    super.key,
    required this.primaryText,
    this.secondaryText = 'Annulla',
    required this.ruleType,
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryIcon,
    this.secondaryIcon,
    this.primaryButtonWidth,
    this.reverseOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        ruleType == RuleType.bonus ? ColorPalette.success : ColorPalette.error;

    // Create the buttons
    final primary = Expanded(
      child: primaryIcon != null
          ? ElevatedButton.icon(
              onPressed: onPrimaryPressed,
              icon: Icon(primaryIcon),
              label: Text(primaryText),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.md,
                  vertical: ThemeSizes.sm,
                ),
                fixedSize: primaryButtonWidth != null
                    ? Size.fromWidth(primaryButtonWidth!)
                    : null,
              ),
            )
          : ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.md,
                  vertical: ThemeSizes.sm,
                ),
                fixedSize: primaryButtonWidth != null
                    ? Size.fromWidth(primaryButtonWidth!)
                    : null,
              ),
              child: Text(primaryText),
            ),
    );

    final secondary = Expanded(
      child: secondaryIcon != null
          ? OutlinedButton.icon(
              onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
              icon: Icon(secondaryIcon),
              label: Text(secondaryText),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.md,
                  vertical: ThemeSizes.sm,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
              child: Text(secondaryText),
            ),
    );

    // Arrange the buttons based on the reverseOrder flag
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: reverseOrder
          ? [primary, const SizedBox(width: ThemeSizes.md), secondary]
          : [secondary, const SizedBox(width: ThemeSizes.md), primary],
    );
  }
}
