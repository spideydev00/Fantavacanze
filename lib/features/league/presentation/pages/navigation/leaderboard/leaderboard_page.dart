import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/leaderboard/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const LeaderboardPage());
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists) {
          final league = state.selectedLeague;

          return Scaffold(
            body: SafeArea(
              child: LeaderboardList(
                league: league,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                emptyStateWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color:
                            context.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun partecipante trovato',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: context.bgColor,
          );
        }

        // No league selected
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: context.textSecondaryColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nessuna lega trovata',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: context.bgColor,
        );
      },
    );
  }
}
