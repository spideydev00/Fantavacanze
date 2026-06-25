import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/leaderboard/leaderboard_list.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/widgets/general_ranking_tab.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerLeagueDashboardPage extends StatelessWidget {
  final League league;

  const PartnerLeagueDashboardPage({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(league.partner);

    return BlocProvider(
      create: (_) => serviceLocator<PartnerCubit>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: Text(
              league.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: brandColor,
              labelColor: context.textPrimaryColor,
              unselectedLabelColor: context.textSecondaryColor,
              tabs: const [
                Tab(
                  icon: Icon(Icons.emoji_events_outlined),
                  text: 'Lega',
                ),
                Tab(
                  icon: Icon(Icons.public_rounded),
                  text: 'Generale',
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _PartnerLeagueHeader(
                league: league,
                color: brandColor,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    LeaderboardList(
                      league: league,
                      padding: const EdgeInsets.all(ThemeSizes.md),
                      emptyStateWidget: const EmptyState(
                        icon: Icons.people_outline,
                        title: 'Nessun partecipante trovato',
                        subtitle:
                            'La classifica della lega apparirà appena arrivano i primi punti.',
                      ),
                    ),
                    GeneralRankingTab(
                      leagueId: league.id,
                      partnerSlug: league.partner,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerLeagueHeader extends StatelessWidget {
  final League league;
  final Color color;

  const _PartnerLeagueHeader({
    required this.league,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.handshake_rounded,
                  color: color,
                  size: ThemeSizes.iconLg,
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Text(
                    league.partner ?? 'Partner',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Classifiche dedicate alla tua lega partner.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
