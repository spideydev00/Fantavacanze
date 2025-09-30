import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_rules_bloc/fs_rules_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/events/fs_event_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/events/fs_events_info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsEventsPage extends StatelessWidget {
  final FsLeague league;

  const FsEventsPage({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FsRulesBloc, FsRulesState>(
      builder: (context, state) {
        final isLoading = state is FsRulesLoading;
        final rules = (state is FsRulesLoaded) ? state.rules : <FsRule>[];
        final completed = _completedOf(rules);

        return CustomScrollView(
          slivers: [
            // Header + banner + divider con conteggio
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const FsEventsInfoBanner(),
                  const SizedBox(height: ThemeSizes.md),
                  // Divisore: mostra il count se abbiamo dati; altrimenti un piccolo loader
                  isLoading && rules.isEmpty
                      ? Loader(color: context.primaryColor)
                      : CustomDivider(
                          text: "Eventi della Serata (${completed.length})",
                          color:
                              context.textSecondaryColor.withValues(alpha: 0.8),
                        ),
                  const SizedBox(height: ThemeSizes.md),
                ],
              ),
            ),

            // Contenuto principale
            if (isLoading && completed.isEmpty)
              SliverToBoxAdapter(child: Loader(color: context.primaryColor))
            else if (completed.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildEmptyStateContent(key: const ValueKey('empty')),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                sliver: SliverList.separated(
                  itemCount: completed.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: ThemeSizes.md),
                  itemBuilder: (context, index) {
                    final rule = completed[index];
                    return FsEventCard(
                      rule: rule,
                      league: league,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // --- HELPERS ---

  static List<FsRule> _completedOf(List<FsRule> all) {
    final list = all.where((r) => r.isCompleted).toList();
    list.sort((a, b) {
      final aTime = a.completedAt ?? a.createdAt;
      final bTime = b.completedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return list;
  }

  Widget _buildEmptyStateContent({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
      child: const EmptyState(
        icon: Icons.cancel_presentation_rounded,
        title: 'Nessun Evento',
        subtitle:
            'Non sono stati completati obiettivi in questa serata. Gli eventi completati appariranno qui.',
      ),
    );
  }
}
