import 'dart:typed_data';

import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/services/share_service.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/animated_share_button.dart';
import 'package:fantavacanze_official/core/widgets/custom_tab.dart';
import 'package:fantavacanze_official/core/widgets/custom_tab_bar.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/participants/participant_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/leaderboard/widgets/index.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/shareable_leaderboard_card.dart';

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
  bool _isSharing = false;

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
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, _) {
        return BlocBuilder<AppLeagueCubit, AppLeagueState>(
          builder: (context, state) {
            if (state is AppLeagueExists) {
              final league = state.selectedLeague;

              if (league.type == LeagueType.team) {
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
                        labelColor: context.textPrimaryColor,
                        unselectedLabelColor: context.textSecondaryColor,
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
                  floatingActionButton: _buildShareFab(context, league),
                  backgroundColor: context.bgColor,
                );
              } else {
                // For individual leagues, just show the leaderboard without tabs
                return Scaffold(
                  body: _buildTeamLeaderboard(context, league),
                  floatingActionButton: _buildShareFab(context, league),
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
      ),
    );
  }

  Widget _buildShareFab(BuildContext context, League league) {
    final navIndex = participantNavbarItems
        .indexWhere((item) => item.screen is LeaderboardPage);
    return Builder(
      builder: (buttonContext) => AnimatedShareButton(
        isLoading: _isSharing,
        triggerOnNavIndex: navIndex >= 0 ? navIndex : null,
        onPressed: () => _onShareLeaderboard(buttonContext, league),
      ),
    );
  }

  Future<void> _onShareLeaderboard(BuildContext context, League league) async {
    final box = context.findRenderObject() as RenderBox?;
    final originRect =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    final isTeam = league.type == LeagueType.team;
    if (isTeam && _tabController.index == 1) {
      final members = _buildMembersListForShare(league);
      await _shareWith(
        context: context,
        league: league,
        membersOverride: members,
        originRect: originRect,
      );
    } else {
      await _shareWith(
        context: context,
        league: league,
        membersOverride: null,
        originRect: originRect,
      );
    }
  }

  Future<void> _shareWith({
    required BuildContext context,
    required League league,
    required List<Map<String, dynamic>>? membersOverride,
    required Rect? originRect,
  }) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      final themeMode = context.read<AppThemeCubit>().state.themeMode;
      final card = ShareableLeaderboardCard(
        league: league,
        membersOverride: membersOverride,
        themeMode: themeMode,
      );
      final shareService = serviceLocator<ShareService>();
      final Uint8List bytes = await shareService.renderWidgetToPng(
        card,
        context: context,
      );

      await shareService.shareImageBytes(
        bytes,
        originRect: originRect,
        filename: 'Classifica Fantavacanze.png',
      );
    } catch (_) {
      showSnackBar('Impossibile condividere la classifica.');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  List<Map<String, dynamic>> _buildMembersListForShare(League league) {
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

    allMembers.sort(
        (a, b) => (b['points'] as double).compareTo(a['points'] as double));
    return allMembers;
  }

  Widget _buildMembersLeaderboard(BuildContext context, League league) {
    final allMembers = _buildMembersListForShare(league);

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
