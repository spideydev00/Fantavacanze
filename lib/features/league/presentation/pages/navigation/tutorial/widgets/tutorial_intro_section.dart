import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class TutorialIntroSection extends StatelessWidget {
  const TutorialIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.info.withValues(alpha: 0.1),
            ColorPalette.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: ColorPalette.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.sm),
                decoration: BoxDecoration(
                  color: ColorPalette.info.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: ColorPalette.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeSizes.md),
              Expanded(
                child: Text(
                  'Benvenuto nei Tutorial',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Scopri come utilizzare al meglio tutte le funzionalità di Fantavacanze attraverso questi video tutorial interattivi.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: ThemeSizes.sm),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: ColorPalette.info,
              ),
              const SizedBox(width: ThemeSizes.xs),
              Expanded(
                child: Text(
                  'Tocca il video per avviarlo e usa i controlli per gestire la riproduzione',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.info,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
