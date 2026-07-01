import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

/// Card informativa usata dalle schermate explainer (admin e utente).
/// Mostra un titolo con icona, un elenco di punti e, opzionalmente, dei consigli.
class ExplainerInfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> children;
  final List<String> tips;

  const ExplainerInfoCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
    this.tips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.md),
          ...children.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      text,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...tips.map(
            (text) => Padding(
              padding: const EdgeInsets.only(top: ThemeSizes.xs),
              child: ExplainerTip(text: text),
            ),
          ),
        ],
      ),
    );
  }
}

/// Box di risalto per un consiglio, in stile [InfoContainer] con icona a stella.
class ExplainerTip extends StatelessWidget {
  final String text;

  const ExplainerTip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    const color = Colors.amber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: color, size: 20),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                "Consiglio",
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.xs),
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
