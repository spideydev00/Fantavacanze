import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/core/widgets/custom_tab.dart';
import 'package:fantavacanze_official/core/widgets/custom_tab_bar.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/participants/participant_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/leaderboard/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const LeaderboardPage());
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists) {
          final league = state.selectedLeague;

          if (league.isTeamBased) {
            return Scaffold(
              body: Column(
                children: [
                  // Use our new custom tab bar instead of AppBar
                  CustomTabBar(
                    controller: _tabController,
                    indicatorColors: [
                      context.secondaryColor,
                      context.primaryColor
                    ],
                    tabs: [
                      CustomTab(
                        label: "SQUADRE",
                        icon: Icons.groups,
                        color: context.secondaryColor,
                      ),
                      CustomTab(
                        label: "GIOCATORI",
                        icon: Icons.person,
                        color: context.primaryColor,
                      ),
                    ],
                  ),

                  // TabBarView with team and members leaderboards
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Team leaderboard
                        _buildTeamLeaderboard(context, league),

                        // Individual members leaderboard
                        _buildMembersLeaderboard(context, league),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: context.bgColor,
            );
          } else {
            // For individual leagues, just show the leaderboard without tabs
            return Scaffold(
              body: _buildTeamLeaderboard(context, league),
              backgroundColor: context.bgColor,
            );
          }
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

  Widget _buildTeamLeaderboard(BuildContext context, League league) {
    return LeaderboardList(
        league: league,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        emptyStateWidget: EmptyState(
          icon: Icons.people_outline,
          title: 'Nessun partecipante trovato',
          subtitle:
              'Controlla se la lega è attiva o se hai partecipato a qualche evento',
        ));
  }

  Widget _buildMembersLeaderboard(BuildContext context, League league) {
    // Extract all members from team participants and sort by points
    final allMembers = <Map<String, dynamic>>[];

    for (final participant in league.participants) {
      if (participant is TeamParticipant) {
        for (final member in participant.members) {
          allMembers.add({
            'userId': member.userId,
            'name': member.name,
            'points': member.points,
            'teamName': participant.name,
            'isCaptain': participant.captainId == member.userId,
            'teamLogoUrl': participant.teamLogoUrl,
          });
        }
      }
    }

    // Sort by points in descending order
    allMembers.sort(
        (a, b) => (b['points'] as double).compareTo(a['points'] as double));

    if (allMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun giocatore trovato',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeSizes.md),
      itemCount: allMembers.length,
      itemBuilder: (context, index) {
        final member = allMembers[index];
        // Format points using our NumberFormatter
        final formattedPoints = NumberFormatter.formatPoints(member['points']);

        // Use our new ParticipantCard for a cleaner, consistent UI
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeSizes.md),
          child: ParticipantCard(
            name: member['name'],
            points: member['points'],
            formattedPoints: formattedPoints, // Pass formatted points
            showPoints: true,
            isFullWidth: true,
            subtitle: '${member['teamName']}',
            avatarUrl: member['teamLogoUrl'],
          ),
        );
      },
    );
  }
}
