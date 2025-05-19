import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

/// A generic confirmation dialog component
///
/// This component displays a confirmation dialog with customizable
/// title, message, icon, and action buttons.
class ConfirmationDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The message to display
  final String message;

  /// The icon to show (defaults to delete_outline)
  final IconData icon;

  /// The color of the icon and confirm button
  final Color color;

  /// Text for the cancel button
  final String cancelText;

  /// Text for the confirm button
  final String confirmText;

  /// Callback when confirm is pressed
  final VoidCallback onConfirm;

  /// Optional callback when cancel is pressed
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.delete_outline,
    required this.color,
    this.cancelText = 'Annulla',
    this.confirmText = 'Conferma',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(ThemeSizes.lg),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),

                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
