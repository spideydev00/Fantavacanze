import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_leaderboard/fs_leaderboard_header.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_leaderboard/fs_leaderboard_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsLeaderboardPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const FsLeaderboardPage());

  const FsLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppFsLeagueCubit, AppFsLeagueState>(
      builder: (context, state) {
        if (state is AppFsLeagueExists) {
          final fsLeague = state.league;

          // Sort FsParticipants by points in descending order
          final sortedParticipants = List.from(fsLeague.participants)
            ..sort((a, b) => b.points.compareTo(a.points));

          if (sortedParticipants.isEmpty) {
            return Scaffold(
              body: Center(
                child: EmptyState(
                  icon: Icons.leaderboard_outlined,
                  title: 'Nessun partecipante trovato',
                  subtitle:
                      'La classifica verrà mostrata quando ci saranno partecipanti nella Fantaserata',
                ),
              ),
              backgroundColor: context.bgColor,
            );
          }

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                children: [
                  // Header with column labels
                  const FsLeaderboardHeader(),

                  // Leaderboard items
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedParticipants.length,
                      itemBuilder: (context, index) {
                        final participant = sortedParticipants[index];
                        return FsLeaderboardItem(
                          participant: participant,
                          position: index + 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: context.bgColor,
          );
        }

        // No Fantaserata league found
        return Scaffold(
          body: Center(
            child: EmptyState(
              icon: Icons.leaderboard_outlined,
              title: 'Nessuna Fantaserata attiva',
              subtitle:
                  'Partecipa o crea una Fantaserata per vedere la classifica',
            ),
          ),
          backgroundColor: context.bgColor,
        );
      },
    );
  }
}
