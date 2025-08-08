import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class TutorialEmptyState extends StatelessWidget {
  const TutorialEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: context.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Tutorial in arrivo',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'I video tutorial saranno disponibili a breve',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
