import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum JoiningAction {
  none,
  joiningTeam,
  creatingTeam,
}

class ChooseTeamPage extends StatefulWidget {
  final League league;
  final String inviteCode;

  const ChooseTeamPage({
    super.key,
    required this.league,
    required this.inviteCode,
  });

  static Route route({
    required League league,
    required String inviteCode,
  }) {
    return MaterialPageRoute(
      builder: (context) => ChooseTeamPage(
        league: league,
        inviteCode: inviteCode,
      ),
    );
  }

  @override
  State<ChooseTeamPage> createState() => _ChooseTeamPageState();
}

class _ChooseTeamPageState extends State<ChooseTeamPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _teamNameController = TextEditingController();
  JoiningAction _joiningAction = JoiningAction.none;
  String? _userId;
  int? _selectedTeamIndex;
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _userId = userState.user.id;
    }

    _teamNameController.addListener(() {
      setState(() {});
    });

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Join an existing team
  void _joinExistingTeam(int teamIndex) {
    if (_userId == null) return;

    setState(() => _joiningAction = JoiningAction.joiningTeam);

    final team = widget.league.participants[teamIndex] as TeamParticipant;
    List<String> updatedMembers = [...team.userIds, _userId!];

    _joinLeague(
      teamName: team.name,
      teamMembers: updatedMembers,
      specificLeagueId: widget.league.id,
    );
  }

  // Create a new team with the current user as captain
  void _createNewTeam() {
    final trimmedName = _teamNameController.text.trim();
    if (_userId == null || trimmedName.isEmpty) return;

    setState(() => _joiningAction = JoiningAction.creatingTeam);

    _joinLeague(
      teamName: trimmedName,
      teamMembers: [_userId!],
    );
  }

  // Join the league after selecting/creating a team
  void _joinLeague({
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) {
    if (_userId == null) return;

    context.read<LeagueBloc>().add(
          JoinLeagueEvent(
            inviteCode: widget.inviteCode,
            teamName: teamName,
            teamMembers: teamMembers,
            specificLeagueId: specificLeagueId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final bool isJoiningTeam = _joiningAction == JoiningAction.joiningTeam;
    final bool isCreatingTeam = _joiningAction == JoiningAction.creatingTeam;

    return Scaffold(
      body: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            showSnackBar(context, state.message);
            setState(() => _joiningAction = JoiningAction.none);
          } else if (state is LeagueSuccess &&
              state.operation == 'join_league') {
            // Navigate to home page and clear previous routes
            Navigator.of(context).popUntil((route) => route.isFirst);
            context.read<AppNavigationCubit>().setIndex(0);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // // Background decoration - subtle patterns or shapes
              // Positioned.fill(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: context.bgColor,
              //       // Add subtle pattern here if desired
              //     ),
              //   ),
              // ),

              // Main content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Animated App Bar with League Info
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: FadeTransition(
                        opacity: _headerAnimation,
                        child: _buildLeagueHeader(),
                      ),
                    ),
                  ),

                  // Main content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.lg,
                        vertical: ThemeSizes.md,
                      ),
                      child: Column(
                        children: [
                          // Info banner
                          InfoBanner(
                            message:
                                "Unisciti a una squadra esistente o creane una nuova per partecipare alla lega",
                            color: ColorPalette.warning,
                          ),

                          const SizedBox(height: ThemeSizes.xl),

                          // Existing teams card - significantly improved
                          if (widget.league.participants.isNotEmpty)
                            _buildExistingTeamsCard(isJoiningTeam),

                          const SizedBox(height: ThemeSizes.lg),

                          // Create new team card - significantly improved
                          _buildCreateTeamCard(isCreatingTeam),

                          const SizedBox(height: ThemeSizes.xl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Advanced league header with parallax effect and visual enhancements
  Widget _buildLeagueHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.secondaryBgColor,
                context.primaryColor,
                context.primaryColor,
              ],
            ),
          ),
        ),

        // // Pattern overlay (optional)
        // Opacity(
        //   opacity: 0.1,
        //   child: Image.asset(
        //     "assets/images/pattern.png",
        //     fit: BoxFit.cover,
        //   ),
        // ),

        // Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        ),

        Positioned.fill(
          top: MediaQuery.of(context).padding.top,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // League icon/avatar
                Hero(
                  tag: 'league_icon_${widget.league.id}',
                  child: Container(
                    width: 90,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 45,
                      color: context.accentColor,
                    ),
                  ),
                ),

                const SizedBox(height: ThemeSizes.md),

                // League name
                Text(
                  widget.league.name,
                  style: context.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // League description
                if (widget.league.description != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.xs,
                      vertical: ThemeSizes.xs,
                    ),
                    child: Text(
                      widget.league.description!,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: ThemeSizes.xl),

                // League type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.md,
                    vertical: ThemeSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Lega a Squadre',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Significantly improved existing teams card
  Widget _buildExistingTeamsCard(bool isJoiningTeam) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups,
                    color: context.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Squadre Esistenti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Seleziona una squadra per unirti',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 5,
            thickness: 1,
            color: ColorPalette.darkGrey.withOpacity(0.1),
          ),

          // Teams list with proper handling for many teams
          Container(
            constraints: const BoxConstraints(
              maxHeight: 300, // Limit height to avoid too much scrolling
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ThemeSizes.borderRadiusLg - 1),
                bottomRight: Radius.circular(ThemeSizes.borderRadiusLg - 1),
              ),
            ),
            child: _buildTeamsList(),
          ),

          // Add join button when a team is selected
          if (_selectedTeamIndex != null)
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: ElevatedButton(
                onPressed: isJoiningTeam
                    ? null
                    : () => _joinExistingTeam(_selectedTeamIndex!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                ),
                child: isJoiningTeam
                    ? const Loader(color: Colors.white)
                    : const Text('Unisciti alla squadra'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                ),
                child: const Text('Seleziona una squadra'),
              ),
            ),
        ],
      ),
    );
  }

  // Significantly improved create team card
  Widget _buildCreateTeamCard(bool isCreatingTeam) {
    bool canCreateTeam =
        _teamNameController.text.trim().isNotEmpty && !isCreatingTeam;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: ColorPalette.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: ColorPalette.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crea una Nuova Squadra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Diventa capitano della tua squadra',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 5,
            thickness: 1,
            color: ColorPalette.darkGrey.withOpacity(0.1),
          ),

          // Team name field
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome della Squadra',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: ThemeSizes.sm),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    hintText: 'Inserisci il nome della tua nuova squadra',
                    prefixIcon: Icon(
                      Icons.group_add,
                      color: _teamNameController.text.isEmpty
                          ? context.textSecondaryColor
                          : ColorPalette.warning,
                    ),
                    fillColor: context.bgColor,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.md,
                      horizontal: ThemeSizes.sm,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: ThemeSizes.md),

                // Create button
                ElevatedButton(
                  onPressed: canCreateTeam ? _createNewTeam : null,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                    backgroundColor: ColorPalette.warning,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        ColorPalette.warning.withOpacity(0.3),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    ),
                  ),
                  child: isCreatingTeam
                      ? const Loader(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: ThemeSizes.sm),
                            const Text('Crea nuova squadra'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Advanced teams list with improved visuals for the team items
  Widget _buildTeamsList() {
    if (widget.league.participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_outlined,
                size: 64,
                color: context.textSecondaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                'Nessuna squadra disponibile',
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Sii il primo a creare una squadra!',
                style: TextStyle(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.league.participants.length > 3
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: widget.league.participants.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: context.borderColor.withOpacity(0.1),
        indent: ThemeSizes.lg,
        endIndent: ThemeSizes.lg,
      ),
      itemBuilder: (context, index) {
        final participant = widget.league.participants[index];
        if (participant is TeamParticipant) {
          final isSelected = _selectedTeamIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                // Toggle selection - deselect if already selected
                _selectedTeamIndex = isSelected ? null : index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.xs,
                vertical: ThemeSizes.xs,
              ),
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Row(
                  children: [
                    // Team icon with animated selection state
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.primaryColor.withOpacity(0.2)
                            : context.primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.group_rounded,
                          color: isSelected
                              ? context.primaryColor
                              : context.primaryColor.withOpacity(0.5),
                          size: 26,
                        ),
                      ),
                    ),

                    const SizedBox(width: ThemeSizes.md),

                    // Team details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: context.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${participant.userIds.length} ${participant.userIds.length == 1 ? 'membro' : 'membri'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected ? context.primaryColor : context.bgColor,
                        border: Border.all(
                          color: isSelected
                              ? context.primaryColor
                              : context.textSecondaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
