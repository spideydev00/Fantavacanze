import 'package:fantavacanze_official/core/constants/tutorial_sections.dart';
import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class TutorialPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const TutorialPage());

  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: tutorialSections.isEmpty
          ? _buildEmptyState(context)
          : _buildTutorialContent(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildTutorialContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header intro
          _buildIntroSection(context),

          const SizedBox(height: ThemeSizes.xl),

          // Tutorial sections
          ...tutorialSections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return _buildTutorialSection(
              context,
              section,
              index + 1,
            );
          }),

          // Bottom spacing
          const SizedBox(height: ThemeSizes.xl),
        ],
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
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

  Widget _buildTutorialSection(
    BuildContext context,
    TutorialSection section,
    int sectionNumber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider with gradient
        GradientSectionDivider(
          text: section.title,
          sectionNumber: sectionNumber,
          color: ColorPalette.info,
        ),

        const SizedBox(height: ThemeSizes.lg),

        // Description
        if (section.description.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
            child: Text(
              section.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.lg),
        ],

        // Platform-specific content: Video su iOS, Screenshot su Android
        Platform.isIOS
            ? _buildVideoSection(context, section)
            : _buildScreenshotSection(context, section),

        const SizedBox(height: ThemeSizes.xl),
      ],
    );
  }

  Widget _buildVideoSection(BuildContext context, TutorialSection section) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterVideoPlayer.forTutorials(
          assetPath: section.videoUrl,
        ),
      ),
    );
  }

  Widget _buildScreenshotSection(
      BuildContext context, TutorialSection section) {
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
          // Header con icona
          Container(
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
                SizedBox(height: 5),
                Text(
                  'Tocca per ingrandire',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.info.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Screenshot cliccabile
          GestureDetector(
            onTap: () => _showFullScreenScreenshot(context, section),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxHeight: 200, // Screenshot piccolo
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
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          size: 48,
                        ),
                        const SizedBox(height: ThemeSizes.sm),
                        Text(
                          'Screenshot non disponibile',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenScreenshot(
      BuildContext context, TutorialSection section) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            // Screenshot a schermo intero
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.asset(
                  section.androidScreenshotPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 64,
                          ),
                          const SizedBox(height: ThemeSizes.md),
                          Text(
                            'Screenshot non disponibile',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Header con titolo e pulsante chiudi
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + ThemeSizes.sm,
                  left: ThemeSizes.md,
                  right: ThemeSizes.md,
                  bottom: ThemeSizes.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer con istruzioni
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: ThemeSizes.md,
                  right: ThemeSizes.md,
                  bottom: MediaQuery.of(context).padding.bottom + ThemeSizes.sm,
                  top: ThemeSizes.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pinch_outlined,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    const SizedBox(width: ThemeSizes.sm),
                    Text(
                      'Pizzica per ingrandire/rimpicciolire',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
