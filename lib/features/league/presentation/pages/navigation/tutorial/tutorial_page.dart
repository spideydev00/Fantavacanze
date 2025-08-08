import 'package:fantavacanze_official/core/constants/tutorial_sections.dart';
import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/tutorial/widgets/tutorial_empty_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/tutorial/widgets/tutorial_intro_section.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/tutorial/widgets/tutorial_video_section.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/tutorial/widgets/tutorial_screenshot_section.dart';
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
          ? const TutorialEmptyState()
          : _buildTutorialContent(context),
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
          const TutorialIntroSection(),

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
            ? TutorialVideoSection(section: section)
            : TutorialScreenshotSection(section: section),

        const SizedBox(height: ThemeSizes.xl),
      ],
    );
  }
}
