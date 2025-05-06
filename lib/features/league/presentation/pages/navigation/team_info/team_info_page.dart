import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/events_list.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/exit_confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/leave_league_button.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/score_card.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/section_card.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/stat_card.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/team_info/team_members_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists) {
          final league = state.selectedLeague;
          final userId =
              (context.read<AppUserCubit>().state as AppUserIsLoggedIn).user.id;

          final isAdmin = context.read<LeagueBloc>().isAdmin();

          // Find user's participant entry
          Participant? userParticipant;
          for (final participant in league.participants) {
            if (league.isTeamBased) {
              if (participant is TeamParticipant &&
                  participant.userIds.contains(userId)) {
                userParticipant = participant;
                break;
              }
            } else {
              if (participant is IndividualParticipant &&
                  participant.userId == userId) {
                userParticipant = participant;
                break;
              }
            }
          }

          return league.isTeamBased
              ? _TeamBasedInfo(
                  league: league,
                  team: userParticipant as TeamParticipant,
                  isAdmin: isAdmin,
                  userId: userId,
                )
              : _IndividualInfo(
                  league: league,
                  participant: userParticipant as IndividualParticipant,
                  isAdmin: isAdmin,
                  userId: userId,
                );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _TeamBasedInfo extends StatefulWidget {
  final League league;
  final TeamParticipant team;
  final bool isAdmin;
  final String userId;

  const _TeamBasedInfo({
    required this.league,
    required this.team,
    required this.isAdmin,
    required this.userId,
  });

  @override
  State<_TeamBasedInfo> createState() => _TeamBasedInfoState();
}

class _TeamBasedInfoState extends State<_TeamBasedInfo>
    with SingleTickerProviderStateMixin {
  final _teamNameController = TextEditingController();
  bool _isEditing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team.name;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _teamNameController.text = widget.team.name;
      }
    });
  }

  void _updateTeamName() {
    if (_teamNameController.text.trim().isEmpty ||
        _teamNameController.text.trim() == widget.team.name) {
      _toggleEdit();
      return;
    }

    context.read<LeagueBloc>().add(
          UpdateTeamNameEvent(
            league: widget.league,
            userId: widget.userId,
            newName: _teamNameController.text.trim(),
          ),
        );

    _toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit =
        widget.isAdmin || widget.team.userIds.contains(widget.userId);
    final members = widget.team.userIds.length;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom app bar with edit buttons
          SliverAppBar(
            expandedHeight: 250,
            floating: true,
            pinned: true,
            stretch: true,
            backgroundColor: context.bgColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.bgColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Team avatar positioned properly to avoid overlap
                    Positioned(
                      top: 50,
                      child: Hero(
                        tag: 'team_avatar_${widget.team.name}',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.primaryColor.withValues(alpha: 0.4),
                                context.primaryColor.withValues(alpha: 0.8),
                                context.primaryColor.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    context.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.group,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
                child: _isEditing
                    ? SizedBox(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.md,
                          ),
                          child: TextField(
                            controller: _teamNameController,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: ThemeSizes.md,
                                vertical: ThemeSizes.xs,
                              ),
                              filled: true,
                              fillColor: context.secondaryBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeSizes.borderRadiusMd),
                                borderSide: BorderSide(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeSizes.borderRadiusMd),
                                borderSide: BorderSide(
                                  color: context.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.team.name,
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.only(
                bottom: _isEditing ? 5 : 16,
                top: 50,
              ), // Increased top padding to avoid overlap with icon
            ),
            actions: [
              if (canEdit && !_isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _toggleEdit,
                    tooltip: 'Modifica nome',
                  ),
                ),
              if (_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.check, color: ColorPalette.success),
                  onPressed: _updateTeamName,
                  tooltip: 'Salva',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ColorPalette.error),
                  onPressed: _toggleEdit,
                  tooltip: 'Annulla',
                ),
              ],
            ],
          ),

          // Team info content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Team badge with member count
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.md,
                        vertical: ThemeSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        border: Border.all(
                          color: context.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: ThemeSizes.xs),
                          Text(
                            '$members membri',
                            style: TextStyle(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Statistics section
                SectionCard(
                  title: 'Statistiche',
                  icon: Icons.bar_chart_rounded,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    child: Column(
                      children: [
                        // Score card
                        ScoreCard(
                          score: widget.team.points.toInt(),
                          color: context.primaryColor,
                        ),

                        const SizedBox(height: ThemeSizes.md),

                        // Bonus and malus stats
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_upward_rounded,
                                label: 'Bonus',
                                value: '${widget.team.bonusTotal}',
                                isBonus: true,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Malus',
                                value: '${widget.team.malusTotal}',
                                isBonus: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Members section
                SectionCard(
                  title: 'Membri del Team',
                  icon: Icons.people_alt_rounded,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    child: TeamMembersList(
                      team: widget.team,
                      admins: widget.league.admins,
                      currentUserId: widget.userId,
                    ),
                  ),
                ),

                // Recent events section
                SectionCard(
                  title: 'Eventi Recenti',
                  icon: Icons.event_note_outlined,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    child: EventsList(
                      league: widget.league,
                      participant: widget.team,
                      isTeamBased: true,
                    ),
                  ),
                ),

                // Leave league button
                const SizedBox(height: ThemeSizes.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.lg,
                    vertical: ThemeSizes.md,
                  ),
                  child: LeaveLeagueButton(
                    onPressed: () => _showExitConfirmationDialog(context),
                    animationController: _animationController,
                    scaleAnimation: _scaleAnimation,
                  ),
                ),
                const SizedBox(height: ThemeSizes.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => ExitConfirmationDialog(
        onConfirm: () {
          context.read<LeagueBloc>().add(
                ExitLeagueEvent(
                  league: widget.league,
                  userId: widget.userId,
                ),
              );
          Navigator.pop(context);
          Navigator.pop(context); // Return to previous screen after exiting
        },
      ),
    );
  }
}

class _IndividualInfo extends StatelessWidget {
  final League league;
  final IndividualParticipant participant;
  final bool isAdmin;
  final String userId;

  const _IndividualInfo({
    required this.league,
    required this.participant,
    required this.isAdmin,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = userId == participant.userId;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom app bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: context.bgColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: context.bgColor,
                ),
                child: Center(
                  child: Hero(
                    tag: 'participant_avatar_${participant.userId}',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.primaryColor.withValues(alpha: 0.5),
                            context.primaryColor.withValues(alpha: 0.8),
                            context.primaryColor.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User name
                Text(
                  participant.name,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // User badge
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.md,
                        vertical: ThemeSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        border: Border.all(
                          color: context.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCurrentUser ? Icons.person : Icons.person_outline,
                            size: 16,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: ThemeSizes.xs),
                          Text(
                            isCurrentUser
                                ? 'Il tuo account'
                                : 'Altro partecipante',
                            style: context.textTheme.labelLarge!.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Statistics section
                SectionCard(
                  title: 'Statistiche',
                  icon: Icons.bar_chart_rounded,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    child: Column(
                      children: [
                        // Score card
                        ScoreCard(
                          score: participant.points.toInt(),
                          color: context.primaryColor,
                        ),

                        const SizedBox(height: ThemeSizes.md),

                        // Bonus and malus stats
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_upward_rounded,
                                label: 'Bonus',
                                value: '${participant.bonusTotal}',
                                isBonus: true,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Malus',
                                value: '${participant.malusTotal}',
                                isBonus: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent events section
                SectionCard(
                  title: 'Eventi Recenti',
                  icon: Icons.event_note_outlined,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    child: EventsList(
                      league: league,
                      participant: participant,
                      isTeamBased: false,
                    ),
                  ),
                ),

                // Leave league button (only for current user)
                if (isCurrentUser) ...[
                  const SizedBox(height: ThemeSizes.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.lg,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showExitConfirmationDialog(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Lascia la Lega'),
                      style: context.elevatedButtonThemeData.style!.copyWith(
                        backgroundColor: WidgetStatePropertyAll(
                          context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: ThemeSizes.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => ExitConfirmationDialog(
        onConfirm: () {
          context.read<LeagueBloc>().add(
                ExitLeagueEvent(
                  league: league,
                  userId: userId,
                ),
              );
          Navigator.pop(context);
          Navigator.pop(context); // Return to previous screen after exiting
        },
      ),
    );
  }
}
