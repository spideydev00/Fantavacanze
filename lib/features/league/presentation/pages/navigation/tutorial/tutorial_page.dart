import 'package:fantavacanze_official/core/constants/tutorial_sections.dart';
import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:flutter/material.dart';

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

        // Video player container
        Container(
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
        ),

        const SizedBox(height: ThemeSizes.xl),
      ],
    );
  }
}
