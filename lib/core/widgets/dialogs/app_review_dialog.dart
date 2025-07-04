import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

class AppReviewDialog extends StatelessWidget {
  const AppReviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
      ),
      backgroundColor: context.secondaryBgColor,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor.withValues(alpha: 0.7),
                    context.secondaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wallet_giftcard_rounded,
                size: 50,
                color: ColorPalette.white,
              ),
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Title
            Text(
              "Un regalo per te!",
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeSizes.md),

            // Description with emotional appeal
            Text(
              "Lascia una recensione e sblocca TUTTE le sfide giornaliere! Il tuo supporto ci aiuta a migliorare e a creare nuovi contenuti per te.",
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textSecondaryColor,
                      side: BorderSide(
                          color: context.textSecondaryColor
                              .withValues(alpha: 0.3)),
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                    ),
                    child: const Text("Non ora"),
                  ),
                ),

                const SizedBox(width: ThemeSizes.md),

                // Accept button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                    ),
                    child: const Text("Recensisci"),
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
