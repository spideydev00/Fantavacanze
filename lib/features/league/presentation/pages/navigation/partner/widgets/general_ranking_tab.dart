import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/leaderboard/leaderboard_header.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_sort.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralRankingTab extends StatefulWidget {
  final String leagueId;
  final String? partnerSlug;

  const GeneralRankingTab({
    super.key,
    required this.leagueId,
    required this.partnerSlug,
  });

  @override
  State<GeneralRankingTab> createState() => _GeneralRankingTabState();
}

class _GeneralRankingTabState extends State<GeneralRankingTab> {
  // Indice della voce "Classifica Globale" nello stack del dashboard.
  static final int _globalRankingIndex = participantNavbarItems
      .indexWhere((item) => item.title == 'Classifica Globale');

  void _reload(BuildContext context) {
    context.read<PartnerCubit>().loadGeneralRanking(widget.leagueId);
  }

  @override
  void initState() {
    super.initState();
    // Carica al mount: con il gate rewarded il tab viene montato dopo lo
    // sblocco, quando l'indice di navigazione è già su "Classifica Globale"
    // (nessuna transizione che faccia scattare il BlocListener). Il listener
    // resta per i refetch sulle visite successive.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(widget.partnerSlug);

    return BlocListener<AppNavigationCubit, int>(
      listenWhen: (prev, curr) =>
          curr == _globalRankingIndex && prev != _globalRankingIndex,
      listener: (context, _) => _reload(context),
      child: BlocBuilder<PartnerCubit, PartnerState>(
        builder: (context, state) {
          return switch (state) {
            PartnerLoading() || PartnerInitial() => Center(
                child: Loader(color: brandColor),
              ),
            PartnerFailure(:final message) => EmptyState(
                icon: Icons.error_outline,
                title: 'Classifica non disponibile',
                subtitle: message,
                action: ElevatedButton(
                  onPressed: () => _reload(context),
                  child: const Text('Riprova'),
                ),
              ),
            PartnerRankingLoaded(:final ranking) =>
              _RankingList(ranking: ranking),
            _ => EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Classifica non disponibile',
                subtitle: 'Riprova tra qualche istante.',
              ),
          };
        },
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<GeneralRankingEntry> ranking;

  const _RankingList({required this.ranking});

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'Classifica vuota',
        subtitle: 'Nessun partecipante ha ancora accumulato punti.',
      );
    }

    final sorted = sortGeneralRanking(ranking);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
      itemCount: sorted.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const LeaderboardHeader(isTeamBased: false);
        }
        return _RankingRow(
          entry: sorted[index - 1],
          position: index,
        );
      },
    );
  }
}

class _RankingRow extends StatelessWidget {
  final GeneralRankingEntry entry;
  final int position;

  const _RankingRow({
    required this.entry,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (position) {
      1 => Colors.amber,
      2 => Colors.grey.shade400,
      3 => Colors.brown.shade300,
      _ => null,
    };

    final points = NumberFormatter.formatPoints(entry.points);
    final bonus = NumberFormatter.formatPoints(entry.bonusTotal);
    final malus = NumberFormatter.formatPoints(entry.malusTotal);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.sm,
        horizontal: ThemeSizes.md,
      ),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: context.textSecondaryColor.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medalColor != null
                ? Icon(Icons.emoji_events, color: medalColor, size: 24)
                : Text(
                    '$position',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  entry.leagueName,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              bonus,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: ColorPalette.success,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              malus,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: ColorPalette.error,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              points,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
