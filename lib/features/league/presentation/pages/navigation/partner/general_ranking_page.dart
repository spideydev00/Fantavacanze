import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/widgets/general_ranking_tab.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralRankingPage extends StatelessWidget {
  const GeneralRankingPage({super.key});

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
              title: const Text('Classifica Generale'),
              centerTitle: true,
            ),
            body: const EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Classifica generale non disponibile',
              subtitle:
                  'La classifica generale e disponibile solo nelle leghe travel partner.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: const Text('Classifica Generale'),
            centerTitle: true,
          ),
          body: BlocProvider(
            create: (_) => serviceLocator<PartnerCubit>(),
            child: GeneralRankingTab(
              leagueId: selectedLeague.id,
              partnerSlug: selectedLeague.partner,
            ),
          ),
        );
      },
    );
  }
}
