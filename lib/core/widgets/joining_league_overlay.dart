import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';

class JoiningLeagueOverlay extends StatelessWidget {
  const JoiningLeagueOverlay({
    super.key,
    this.title = 'Unione alla lega in corso...',
    this.subtitle = 'Attendi il completamento',
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: Card(
              color: context.colorScheme.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Loader(color: context.primaryColor),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: ThemeSizes.xs),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontSize: ThemeSizes.labelMd,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
