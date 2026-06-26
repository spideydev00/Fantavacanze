import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/ambient_glow.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/action_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/create_partner_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/search_partner_league_page.dart';
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
    return Theme(
      data: AppTheme.getTheme(context, partnerSlugOverride: 'invibe'),
      child: Builder(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: Text('Partner', style: context.textTheme.bodyLarge),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: AmbientGlow(
            child: SizedBox.expand(
              child: SafeArea(
                child: BlocBuilder<PartnerCubit, PartnerState>(
                  builder: (context, state) {
                    return switch (state) {
                      PartnerInitial() || PartnerLoading() => Center(
                          child: SizedBox(
                            width: ThemeSizes.loadingIndicatorSize,
                            height: ThemeSizes.loadingIndicatorSize,
                            child: Loader(color: context.brandColor),
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
                      PartnerDestinationsLoaded(:final catalog) =>
                        _LoadedDashboard(
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
            ),
          ),
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
    final brand = context.brandColor;
    final cubit = context.read<PartnerCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoContainer(
                title: 'Le tue leghe InVibe',
                message:
                    'Ogni lega è per il tuo gruppo di amici. Presto arriverà anche una classifica generale tra tutte le leghe della destinazione!',
                icon: Icons.groups_rounded,
                color: brand,
              ),
              const SizedBox(height: ThemeSizes.lg),
              ActionCard(
                title: 'Crea una lega',
                description: 'Parti da una destinazione e invita i tuoi amici.',
                imagePath: 'assets/images/invibe-card-bg.jpeg',
                iconData: Icons.add_circle_outline,
                iconGlowColor: brand,
                showBottomGradient: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: CreatePartnerLeaguePage(catalog: catalog),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              ActionCard(
                title: 'Unisciti a una lega',
                description: 'Hai un codice? Inseriscilo e parti.',
                imagePath: 'assets/images/add-event-bg.jpg',
                iconData: Icons.login_rounded,
                iconGlowColor: brand,
                showBottomGradient: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: SearchPartnerLeaguePage(
                        partnerSlug: catalog.partner.slug,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
