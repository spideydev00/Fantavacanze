import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportContactDialog extends StatelessWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SupportContactDialog(),
    );
  }

  const SupportContactDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const String supportEmail = 'supporto@fantavacanze.it';

    return Dialog(
      backgroundColor: context.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Contatta il Supporto',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // Support Icon
            CircleAvatar(
              radius: 40,
              backgroundColor: context.secondaryBgColor,
              child: Icon(
                Icons.support_agent,
                size: 40,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // Support Message
            Text(
              'Per qualsiasi problema o suggerimento, contattaci alla seguente email:',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Support Email with Copy
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: supportEmail));
                showSnackBar(
                  'Email copiata negli appunti',
                  color: ColorPalette.success,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    supportEmail,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.xs),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: context.secondaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }
}
