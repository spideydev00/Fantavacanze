import 'dart:typed_data';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/services/share_service.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/animated_share_button.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_sort.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/leaderboard/widgets/shareable_leaderboard_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/widgets/general_ranking_tab.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralRankingPage extends StatefulWidget {
  const GeneralRankingPage({super.key});

  @override
  State<GeneralRankingPage> createState() => _GeneralRankingPageState();
}

class _GeneralRankingPageState extends State<GeneralRankingPage> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        final selectedLeague =
            state is AppLeagueExists ? state.selectedLeague : null;

        if (selectedLeague == null ||
            selectedLeague.partner == null ||
            selectedLeague.partnerRoundId == null) {
          return Scaffold(
            backgroundColor: context.bgColor,
            appBar: AppBar(
              title: Text(
                'Classifica Globale',
                style: context.textTheme.bodyLarge,
              ),
              centerTitle: true,
            ),
            body: const EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Classifica globale non disponibile',
              subtitle:
                  'La classifica globale è disponibile solo nelle leghe travel partner.',
            ),
          );
        }

        return BlocProvider(
          create: (_) => serviceLocator<PartnerCubit>(),
          child: Builder(
            builder: (innerContext) {
              return Scaffold(
                backgroundColor: context.bgColor,
                appBar: AppBar(
                  title: Text(
                    'Classifica Globale',
                    style: context.textTheme.bodyLarge,
                  ),
                  centerTitle: true,
                ),
                body: GeneralRankingTab(
                  leagueId: selectedLeague.id,
                  partnerSlug: selectedLeague.partner,
                ),
                floatingActionButton:
                    _buildShareFab(innerContext, selectedLeague),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShareFab(BuildContext cubitContext, League league) {
    return BlocBuilder<PartnerCubit, PartnerState>(
      bloc: cubitContext.read<PartnerCubit>(),
      builder: (context, state) {
        if (state is! PartnerRankingLoaded || state.ranking.isEmpty) {
          return const SizedBox.shrink();
        }
        return AnimatedShareButton(
          isLoading: _isSharing,
          onPressed: () => _onShare(cubitContext, league, state.ranking),
        );
      },
    );
  }

  Future<void> _onShare(
    BuildContext context,
    League league,
    List<GeneralRankingEntry> ranking,
  ) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      final members = sortGeneralRanking(ranking)
          .map((entry) => <String, dynamic>{
                'name': entry.name,
                'points': entry.points,
                'bonusTotal': entry.bonusTotal,
                'malusTotal': entry.malusTotal,
              })
          .toList();

      final themeMode = context.read<AppThemeCubit>().state.themeMode;
      final card = ShareableLeaderboardCard(
        league: league,
        membersOverride: members,
        themeMode: themeMode,
        titleOverride: 'Classifica Globale',
      );

      final box = context.findRenderObject() as RenderBox?;
      final originRect =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      final shareService = serviceLocator<ShareService>();
      final Uint8List bytes = await shareService.renderWidgetToPng(
        card,
        context: context,
      );

      await shareService.shareImageBytes(
        bytes,
        originRect: originRect,
        filename: 'Classifica Globale Fantavacanze.png',
      );
    } catch (_) {
      showSnackBar('Impossibile condividere la classifica.');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
