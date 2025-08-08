import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/tutorial/widgets/fullscreen_screenshot_dialog.dart';
import 'package:flutter/material.dart';

class TutorialScreenshotSection extends StatelessWidget {
  final TutorialSection section;

  const TutorialScreenshotSection({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildScreenshot(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.md),
      color: ColorPalette.info.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.screenshot_outlined,
                color: ColorPalette.info,
                size: 20,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                'Foto Tutorial',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Tocca per ingrandire',
            style: context.textTheme.bodySmall?.copyWith(
              color: ColorPalette.info.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshot(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenScreenshot(context),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 200,
        ),
        child: Image.asset(
          section.androidScreenshotPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: context.colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 48,
                  ),
                  const SizedBox(height: ThemeSizes.sm),
                  Text(
                    'Screenshot non disponibile',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenScreenshot(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FullscreenScreenshotDialog(section: section),
    );
  }
}
