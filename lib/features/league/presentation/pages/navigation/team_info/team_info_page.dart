import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/utils/image_picker_util.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/leave_league_button.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/score_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/section_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/stat_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/team_members_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/widgets/events/events_list_widget.dart';

class TeamInfoPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const TeamInfoPage());
  const TeamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueError) {
          // Show error message in a snackbar
          showSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<AppLeagueCubit, AppLeagueState>(
        builder: (context, state) {
          if (state is AppLeagueExists) {
            final league = state.selectedLeague;

            final userId =
                (context.read<AppUserCubit>().state as AppUserIsLoggedIn)
                    .user
                    .id;

            final isAdmin = context.read<LeagueBloc>().isAdmin();

            late bool isCaptain = false;

            if (league.isTeamBased) {
              // Find if user is a captain of any team
              for (final participant in league.participants) {
                if (participant is TeamParticipant) {
                  if (participant.captainId == userId) {
                    isCaptain = true;
                    break;
                  }
                }
              }
            }

            // Find user's participant entry
            Participant? userParticipant;
            for (final participant in league.participants) {
              if (league.isTeamBased) {
                if (participant is TeamParticipant &&
                    participant.members
                        .any((member) => member.userId == userId)) {
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
                    isCaptain: isCaptain,
                    userId: userId,
                  )
                : _IndividualInfo(
                    league: league,
                    participant: userParticipant as IndividualParticipant,
                    isAdmin: isAdmin,
                    userId: userId,
                  );
          }

          return Center(
            child: Loader(color: context.primaryColor),
          );
        },
      ),
    );
  }
}

// D I S P L A Y   I N F O R M A T I O N
// for Team Participants
class _TeamBasedInfo extends StatefulWidget {
  final League league;
  final TeamParticipant team;
  final bool isCaptain;
  final String userId;

  const _TeamBasedInfo({
    required this.league,
    required this.team,
    required this.isCaptain,
    required this.userId,
  });

  @override
  State<_TeamBasedInfo> createState() => _TeamBasedInfoState();
}

class _TeamBasedInfoState extends State<_TeamBasedInfo>
    with SingleTickerProviderStateMixin {
  final _teamNameController = TextEditingController();
  bool _isEditing = false;
  bool _isRemovingMembers = false;
  final GlobalKey<TeamMembersListState> _teamMembersListKey =
      GlobalKey<TeamMembersListState>();
  late AnimationController _animationController;
  String? _pendingTeamLogoUrl;
  bool _isUploadingLogo = false;

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team.name;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  void _toggleRemovalMode() {
    setState(() {
      _isRemovingMembers = !_isRemovingMembers;
      if (_teamMembersListKey.currentState != null) {
        _teamMembersListKey.currentState!.toggleRemovalMode();
      }
    });
  }

  void _onRemovalModeChanged(bool isRemoving) {
    if (_isRemovingMembers != isRemoving) {
      setState(() {
        _isRemovingMembers = isRemoving;
      });
    }
  }

  void _handleTeamLogoUpdate() async {
    final isAdmin = widget.league.admins.contains(widget.userId);
    final canEdit = widget.isCaptain || isAdmin;

    if (!canEdit) {
      showSnackBar(
          context, 'Solo il capitano o gli admin possono modificare il logo');
      return;
    }

    final imageFile = await ImagePickerUtil.pickImage(
      context: context,
      enableCropping: true,
      isCircular: true,
      aspectRatio: 1.0,
    );

    if (imageFile == null) return;

    setState(() {
      _isUploadingLogo = true;
    });

    // First upload the image file using team name instead of ID
    if (mounted) {
      context.read<LeagueBloc>().add(
            UploadTeamLogoEvent(
              leagueId: widget.league.id,
              teamName: widget.team.name,
              imageFile: imageFile,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.league.admins.contains(widget.userId);
    final canEdit = widget.isCaptain || isAdmin;
    final members = widget.team.userIds.length;

    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is TeamLogoUploadSuccess) {
          if (state.teamName == widget.team.name) {
            // Check team name instead of ID
            _pendingTeamLogoUrl = state.logoUrl;

            // Update the team with the new logo URL
            context.read<LeagueBloc>().add(
                  UpdateTeamLogoEvent(
                    league: widget.league,
                    teamName: widget.team.name,
                    logoUrl: state.logoUrl,
                  ),
                );
          }
        } else if (state is LeagueSuccess &&
            state.operation == 'update_team_logo') {
          setState(() {
            _isUploadingLogo = false;
            _pendingTeamLogoUrl = null;
          });

          showSnackBar(
            context,
            'Logo del team aggiornato con successo',
            color: ColorPalette.success,
          );
        } else if (state is LeagueError) {
          setState(() {
            _isUploadingLogo = false;
            _pendingTeamLogoUrl = null;
          });
          showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
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
                        child: GestureDetector(
                          onTap: _isEditing && canEdit
                              ? _handleTeamLogoUpdate
                              : null, // Only allow editing when in edit mode
                          child: Hero(
                            tag: 'team_avatar_${widget.team.name}',
                            child: _buildTeamAvatar(context),
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
                            score: widget.team.points,
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
                    // Add trash icon action for captain or admin
                    actionButton: canEdit
                        ? GestureDetector(
                            onTap: _toggleRemovalMode,
                            child: Icon(
                              _isRemovingMembers
                                  ? Icons.close
                                  : Icons.delete_outline,
                              color: _isRemovingMembers
                                  ? ColorPalette.error
                                  : context.textSecondaryColor,
                            ),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(ThemeSizes.md),
                      child: TeamMembersList(
                        key: _teamMembersListKey,
                        team: widget.team,
                        admins: widget.league.admins,
                        currentUserId: widget.userId,
                        isCaptain: widget.isCaptain,
                        onRemovalModeChanged: _onRemovalModeChanged,
                      ),
                    ),
                  ),

                  // Recent events section
                  SectionCard(
                    title: 'Eventi recenti',
                    icon: Icons.event_note,
                    child: EventsListWidget(
                      league: widget.league,
                      participant: widget.team,
                      limit: 5,
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
                      onPressed: () => _showExitConfirmationDialog(
                        context,
                        widget.league,
                        widget.userId,
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamAvatar(BuildContext context) {
    // Check if team has a logo or if we have a pending logo
    final hasLogo =
        widget.team.teamLogoUrl != null || _pendingTeamLogoUrl != null;
    final logoUrl = _pendingTeamLogoUrl ?? widget.team.teamLogoUrl;
    final isAdmin = widget.league.admins.contains(widget.userId);
    final canEdit = widget.isCaptain || isAdmin;

    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: hasLogo
                ? null
                : LinearGradient(
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
                color: context.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: hasLogo
                ? CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: context.primaryColor.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.primaryColor.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.group,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.group,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        // Show loading indicator when uploading
        if (_isUploadingLogo)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),

        if (canEdit && _isEditing && !_isUploadingLogo)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.textPrimaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.edit,
                color: context.primaryColor,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}

// D I S P L A Y   I N F O R M A T I O N
// for Individual Participants
class _IndividualInfo extends StatefulWidget {
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
  State<_IndividualInfo> createState() => _IndividualInfoState();
}

class _IndividualInfoState extends State<_IndividualInfo> {
  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userId == widget.participant.userId;

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
                    tag: 'participant_avatar_${widget.participant.userId}',
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
                  widget.participant.name,
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
                          score: widget.participant.points,
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
                                value: '${widget.participant.bonusTotal}',
                                isBonus: true,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Malus',
                                value: '${widget.participant.malusTotal}',
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
                  title: 'Eventi recenti',
                  icon: Icons.event_note,
                  child: EventsListWidget(
                    league: widget.league,
                    participant: widget.participant,
                    limit: 5,
                  ),
                ),

                // Leave league button (only for current user)
                if (isCurrentUser) ...[
                  const SizedBox(height: ThemeSizes.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.lg,
                      vertical: ThemeSizes.md,
                    ),
                    child: LeaveLeagueButton(
                      onPressed: () => _showExitConfirmationDialog(
                        context,
                        widget.league,
                        widget.userId,
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
}

// S H O W   E X I T   C O N F I R M A T I O N   D I A L O G
// Function to show exit confirmation dialog
// and handle exit logic
Future<void> _showExitConfirmationDialog(
  BuildContext context,
  League league,
  String userId,
) async {
  return showDialog(
    context: context,
    builder: (context) => ConfirmationDialog.exitLeague(
      onExit: () async {
        final leagueBloc = context.read<LeagueBloc>();
        final appNavigationCubit = context.read<AppNavigationCubit>();

        if (context.mounted) {
          // Mostra il dialog di uscita
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              // Avvia il timer di 1 secondo
              Future.delayed(const Duration(seconds: 1), () {
                if (dialogContext.mounted) {
                  // Esegui l'evento di uscita
                  leagueBloc.add(
                    ExitLeagueEvent(
                      league: league,
                      userId: userId,
                    ),
                  );
                  // Chiude il dialog di loading
                  Navigator.of(dialogContext).pop();
                  // Torna alla home
                  appNavigationCubit.setIndex(0);
                }
              });

              return PopScope(
                canPop: false,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: dialogContext.secondaryBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Loader(color: context.primaryColor),
                          const SizedBox(height: 24),
                          Text(
                            'Uscita in corso...',
                            style: dialogContext.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    ),
  );
}
