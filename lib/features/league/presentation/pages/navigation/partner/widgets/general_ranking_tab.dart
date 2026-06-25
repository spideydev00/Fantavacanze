import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PartnerCubit>().loadGeneralRanking(widget.leagueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(widget.partnerSlug);

    return BlocBuilder<PartnerCubit, PartnerState>(
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
                onPressed: () => context
                    .read<PartnerCubit>()
                    .loadGeneralRanking(widget.leagueId),
                child: const Text('Riprova'),
              ),
            ),
          PartnerRankingLoaded(:final ranking) => _RankingList(
              ranking: ranking,
              brandColor: brandColor,
            ),
          _ => EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Classifica non disponibile',
              subtitle: 'Riprova tra qualche istante.',
            ),
        };
      },
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<GeneralRankingEntry> ranking;
  final Color brandColor;

  const _RankingList({
    required this.ranking,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'Classifica vuota',
        subtitle: 'Nessun partecipante ha ancora accumulato punti.',
      );
    }

    final sorted = List<GeneralRankingEntry>.from(ranking)
      ..sort((a, b) => b.points.compareTo(a.points));

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeSizes.md),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        return _RankingRow(
          entry: sorted[index],
          position: index + 1,
          brandColor: brandColor,
        );
      },
    );
  }
}

class _RankingRow extends StatelessWidget {
  final GeneralRankingEntry entry;
  final int position;
  final Color brandColor;

  const _RankingRow({
    required this.entry,
    required this.position,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusMd),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ThemeSizes.xl,
            child: Text(
              '$position',
              style: context.textTheme.titleMedium?.copyWith(
                color: brandColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: brandColor.withValues(alpha: 0.14),
            child: Icon(
              Icons.person,
              color: brandColor,
              size: ThemeSizes.iconSm,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: ThemeSizes.xs),
                Text(
                  entry.leagueName,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Text(
            '${NumberFormatter.formatPoints(entry.points)} pt',
            style: context.textTheme.titleMedium?.copyWith(
              color: brandColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
