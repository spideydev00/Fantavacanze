import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ExitConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeSizes.md),
              decoration: BoxDecoration(
                color: ColorPalette.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: ColorPalette.error,
                size: 38,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Lascia la Lega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Sei sicuro di voler uscire da questa lega? Questa azione non può essere annullata.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annulla',
                    ),
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: context.elevatedButtonThemeData.style!.copyWith(
                      backgroundColor:
                          WidgetStatePropertyAll(context.primaryColor),
                    ),
                    child: const Text('Esci'),
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
