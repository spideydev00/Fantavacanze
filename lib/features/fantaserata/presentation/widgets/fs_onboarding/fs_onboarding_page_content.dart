import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsOnboardingPageContent extends StatelessWidget {
  const FsOnboardingPageContent({
    super.key,
    required this.title,
    required this.subtitle,
    this.ySpace = 0,
    this.alignment = MainAxisAlignment.center,
  });

  final String title;
  final String subtitle;
  final double ySpace;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.xxl),
      child: Column(
        mainAxisAlignment: alignment,
        children: [
          SizedBox(height: ySpace),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall!.copyWith(
              fontFamily: "Falcon Sport One",
              color: ColorPalette.white,
              shadows: [
                const Shadow(
                  color: ColorPalette.darkerGrey,
                  blurRadius: 55.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorPalette.textPrimary(
                ThemeMode.dark,
              ),
              shadows: [
                const Shadow(
                  color: ColorPalette.darkerGrey,
                  blurRadius: 55.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
