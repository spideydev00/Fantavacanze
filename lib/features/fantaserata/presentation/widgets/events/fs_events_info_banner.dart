import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsEventsInfoBanner extends StatelessWidget {
  const FsEventsInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primary(themeMode).withValues(alpha: 0.1),
            ColorPalette.accent(themeMode).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: ColorPalette.primary(themeMode).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeSizes.sm),
            decoration: BoxDecoration(
              color: ColorPalette.primary(themeMode).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: ColorPalette.primary(themeMode),
              size: ThemeSizes.iconSm,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Obiettivi Completati',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: ThemeSizes.xs),
                Text(
                  'Qui trovi tutti gli obiettivi completati. Qualcuno ha fatto il furbo? Scorri verso destra su un obiettivo per riattivarlo e rimuovere i punti all\'utente.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
