import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:flutter/material.dart';

class TutorialVideoSection extends StatelessWidget {
  final TutorialSection section;

  const TutorialVideoSection({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
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
}
