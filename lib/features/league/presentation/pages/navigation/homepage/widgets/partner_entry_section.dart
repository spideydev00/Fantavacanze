import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_dashboard_page.dart';
import 'package:flutter/material.dart';

class PartnerEntrySection extends StatelessWidget {
  static const String _partnerSlug = 'invibe';

  const PartnerEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(_partnerSlug);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(
            text: 'InVibe',
            color: brandColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _PartnerCard(
                brandColor: brandColor,
                onTap: () => Navigator.push(
                  context,
                  PartnerDashboardPage.route(_partnerSlug),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final Color brandColor;
  final VoidCallback onTap;

  const _PartnerCard({
    required this.brandColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final logo = BrandAssets.logoFor(PartnerEntrySection._partnerSlug);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeSizes.lg),
          decoration: BoxDecoration(
            color: brandColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
            border: Border.all(color: brandColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              _PartnerMark(
                color: brandColor,
                logo: logo,
              ),
              const SizedBox(width: ThemeSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leghe travel InVibe',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.xs),
                    Text(
                      'Crea o cerca una lega dedicata al tuo viaggio.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThemeSizes.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: brandColor,
                size: ThemeSizes.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerMark extends StatelessWidget {
  final Color color;
  final String? logo;

  const _PartnerMark({
    required this.color,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ThemeSizes.xxl,
      height: ThemeSizes.xxl,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: logo == null
          ? Icon(
              Icons.travel_explore_rounded,
              color: color,
              size: ThemeSizes.iconMd,
            )
          : Padding(
              padding: const EdgeInsets.all(ThemeSizes.xs),
              child: Image.asset(
                logo!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.travel_explore_rounded,
                  color: color,
                  size: ThemeSizes.iconMd,
                ),
              ),
            ),
    );
  }
}
