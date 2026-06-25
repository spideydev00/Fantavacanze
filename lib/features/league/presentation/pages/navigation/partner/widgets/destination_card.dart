import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';

class DestinationCard extends StatelessWidget {
  final PartnerDestination destination;
  final bool selected;
  final String? partnerSlug;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.selected,
    required this.partnerSlug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(partnerSlug);

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeSizes.md),
      elevation: selected ? ThemeSizes.cardElevation : 0,
      color: context.secondaryBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        side: BorderSide(
          color: selected ? brandColor : context.borderColor,
          width: selected
              ? ThemeSizes.dividerHeight * 2
              : ThemeSizes.dividerHeight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DestinationImage(
                    imageUrl: destination.imageUrl,
                    color: brandColor,
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (destination.description != null) ...[
                          const SizedBox(height: ThemeSizes.xs),
                          Text(
                            destination.description!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (destination.activeRound != null) ...[
                          const SizedBox(height: ThemeSizes.sm),
                          _RoundChip(
                            label: _roundLabel(destination),
                            color: brandColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? brandColor : context.textSecondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: ThemeSizes.md),
              _RulesPreview(rules: destination.rules),
            ],
          ),
        ),
      ),
    );
  }

  String _roundLabel(PartnerDestination destination) {
    final round = destination.activeRound;
    if (round == null) return '';
    final start = _formatDate(round.startDate);
    final end = round.endDate == null ? null : _formatDate(round.endDate!);
    if (end == null) return '${round.name} · dal $start';
    return '${round.name} · $start - $end';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _DestinationImage extends StatelessWidget {
  final String? imageUrl;
  final Color color;

  const _DestinationImage({
    required this.imageUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = ThemeSizes.imageThumbSize;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusMd),
        ),
        child: Icon(
          Icons.place_rounded,
          color: color,
          size: ThemeSizes.iconLg,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusMd),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(
          width: size,
          height: size,
          color: color.withValues(alpha: 0.14),
          child: Icon(Icons.place_rounded, color: color),
        ),
      ),
    );
  }
}

class _RoundChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RoundChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.sm,
        vertical: ThemeSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RulesPreview extends StatelessWidget {
  final List<Rule> rules;

  const _RulesPreview({required this.rules});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return Text(
        'Regolamento non ancora disponibile.',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.textSecondaryColor,
        ),
      );
    }

    final visibleRules = rules.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anteprima regolamento',
          style: context.textTheme.labelLarge?.copyWith(
            color: context.textSecondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.xs),
        for (final rule in visibleRules)
          Padding(
            padding: const EdgeInsets.only(bottom: ThemeSizes.xs),
            child: Row(
              children: [
                Icon(
                  rule.type == RuleType.bonus
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color: rule.type == RuleType.bonus
                      ? ColorPalette.success
                      : ColorPalette.error,
                  size: ThemeSizes.iconSm,
                ),
                const SizedBox(width: ThemeSizes.sm),
                Expanded(
                  child: Text(
                    rule.name,
                    style: context.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (rules.length > visibleRules.length)
          Text(
            '+${rules.length - visibleRules.length} regole',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
