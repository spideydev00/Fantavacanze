import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.readingTime,
  });

  final String imagePath;
  final String title;
  final String readingTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.xl,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorPalette.secondaryBg,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: ThemeSizes.imageThumbSizeLg,
            width: double.infinity, // Ensures image takes full width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  readingTime,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: ColorPalette.darkGrey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
