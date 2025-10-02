import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FsHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? svgIconPath;
  final VoidCallback onTap;
  final List<Color> gradients;

  const FsHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.svgIconPath,
    required this.onTap,
    this.gradients = ColorPalette.fsGradients,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Take full width
        padding: const EdgeInsets.all(ThemeSizes.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients,
          ),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: context.ternaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            icon != null
                ? Icon(
                    icon,
                    size: 60,
                    color: Colors.white,
                  )
                : svgIconPath != null
                    ? SvgPicture.asset(
                        svgIconPath!,
                        width: 80,
                      )
                    : SizedBox.shrink(),
            const SizedBox(height: ThemeSizes.md),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    color: Color.fromARGB(56, 91, 91, 91),
                    blurRadius: 20.0,
                  ),
                  const Shadow(
                    color: Color.fromARGB(56, 35, 35, 35),
                    blurRadius: 30.0,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  const Shadow(
                    color: Color.fromARGB(97, 91, 91, 91),
                    blurRadius: 10.0,
                  ),
                  const Shadow(
                    color: Color.fromARGB(91, 35, 35, 35),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
