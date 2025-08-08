import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AppInfoDialog(),
    );
  }

  const AppInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Informazioni App',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // App Logo
            CircleAvatar(
              radius: 40,
              backgroundColor: ColorPalette.secondaryBgColor(ThemeMode.dark),
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // App Version
            Text(
              'Fantavacanze',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              //TODO: Replace with actual version from pubspec.yaml
              'Versione 1.1.0',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // App Description
            Text(
              'Fantavacanze è un\'app che ti permette di sfidarti con i tuoi amici in vacanza, creando competizioni personalizzate e guadagnando punti per attività divertenti.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
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
