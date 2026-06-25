import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/buttons/page_redirection_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/create_partner_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/search_partner_league_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerEntryCard extends StatelessWidget {
  final PartnerCatalog catalog;

  const PartnerEntryCard({
    super.key,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(catalog.partner.slug);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        border: Border.all(color: brandColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cosa vuoi fare?',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.xs),
          Text(
            'Crea una nuova lega partner o cercane una già esistente.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeSizes.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  (constraints.maxWidth - ThemeSizes.md).clamp(0.0, 180.0);
              final buttons = [
                PageRedirectionCard(
                  title: 'Crea Lega',
                  icon: Icons.add_circle_outline,
                  width: cardWidth,
                  height: ThemeSizes.xxl * 3,
                  onPressed: () => _openCreate(context),
                ),
                PageRedirectionCard(
                  title: 'Cerca Lega',
                  icon: Icons.search_rounded,
                  width: cardWidth,
                  height: ThemeSizes.xxl * 3,
                  onPressed: () => _openSearch(context),
                ),
              ];

              if (constraints.maxWidth < ThemeSizes.xxl * 6) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: buttons[0]),
                    const SizedBox(height: ThemeSizes.md),
                    SizedBox(width: double.infinity, child: buttons[1]),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buttons[0],
                  const SizedBox(width: ThemeSizes.md),
                  buttons[1],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _openCreate(BuildContext context) {
    final cubit = context.read<PartnerCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CreatePartnerLeaguePage(catalog: catalog),
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    final cubit = context.read<PartnerCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: SearchPartnerLeaguePage(partnerSlug: catalog.partner.slug),
        ),
      ),
    );
  }
}
