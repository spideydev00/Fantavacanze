import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/widgets/partner_entry_card.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerDashboardPage extends StatelessWidget {
  final String partnerSlug;

  const PartnerDashboardPage({
    super.key,
    required this.partnerSlug,
  });

  static Route route(String partnerSlug) {
    return MaterialPageRoute(
      builder: (_) => PartnerDashboardPage(partnerSlug: partnerSlug),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<PartnerCubit>()..loadDestinations(partnerSlug),
      child: _PartnerDashboardView(partnerSlug: partnerSlug),
    );
  }
}

class _PartnerDashboardView extends StatelessWidget {
  final String partnerSlug;

  const _PartnerDashboardView({required this.partnerSlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Partner'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<PartnerCubit, PartnerState>(
          builder: (context, state) {
            return switch (state) {
              PartnerInitial() || PartnerLoading() => Center(
                  child: SizedBox(
                    width: ThemeSizes.loadingIndicatorSize,
                    height: ThemeSizes.loadingIndicatorSize,
                    child:
                        Loader(color: context.brandPrimaryColor(partnerSlug)),
                  ),
                ),
              PartnerFailure(:final message) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Impossibile caricare il partner',
                  subtitle: message,
                  action: ElevatedButton(
                    onPressed: () => context
                        .read<PartnerCubit>()
                        .loadDestinations(partnerSlug),
                    child: const Text('Riprova'),
                  ),
                ),
              PartnerDestinationsLoaded(:final catalog) => _LoadedDashboard(
                  catalog: catalog,
                ),
              _ => EmptyState(
                  icon: Icons.handshake_outlined,
                  title: 'Partner non disponibile',
                  subtitle: 'Torna indietro e riprova tra poco.',
                ),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedDashboard extends StatelessWidget {
  final PartnerCatalog catalog;

  const _LoadedDashboard({required this.catalog});

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(catalog.partner.slug);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
                  border: Border.all(color: brandColor.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.handshake_rounded,
                      color: brandColor,
                      size: ThemeSizes.iconXl,
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      catalog.partner.name,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Text(
                      'Scegli una destinazione partner, crea una lega dedicata o entra in quella del tuo gruppo.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              PartnerEntryCard(catalog: catalog),
            ],
          ),
        ),
      ),
    );
  }
}
