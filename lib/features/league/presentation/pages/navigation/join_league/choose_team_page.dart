import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
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
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ------------------------------
/// Stato delle azioni di join/creazione squadra
/// ------------------------------
enum JoiningAction {
  none,
  joiningTeam,
  creatingTeam,
}

/// ------------------------------
/// Pagina per scegliere o creare squadra in una lega a squadre
/// ------------------------------
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

  /// ------------------------------
  /// initState: recupera userId e avvia animazione header
  /// ------------------------------
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

  /// ------------------------------
  /// dispose: libera controller text e animazione
  /// ------------------------------
  @override
  void dispose() {
    _teamNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ------------------------------
  /// _joinExistingTeam: aggiunge utente a squadra esistente
  /// ------------------------------
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

  /// ------------------------------
  /// _createNewTeam: crea nuova squadra e diventa capitano
  /// ------------------------------
  void _createNewTeam() {
    FocusManager.instance.primaryFocus?.unfocus();

    final trimmedName = _teamNameController.text.trim();
    if (_userId == null || trimmedName.isEmpty) return;
    setState(() => _joiningAction = JoiningAction.creatingTeam);

    _joinLeague(
      teamName: trimmedName,
      teamMembers: [_userId!],
    );
  }

  /// ------------------------------
  /// _joinLeague: invia evento di join/creazione al bloc
  /// ------------------------------
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

  /// ------------------------------
  /// build: struttura principale con listener Bloc e scroll view
  /// ------------------------------
  @override
  Widget build(BuildContext context) {
    final bool isJoiningTeam = _joiningAction == JoiningAction.joiningTeam;
    final bool isCreatingTeam = _joiningAction == JoiningAction.creatingTeam;

    return Scaffold(
      body: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            showSnackBar(state.message);
            setState(() => _joiningAction = JoiningAction.none);
          } else if (state is LeagueSuccess &&
              state.operation == 'join_league') {
            Navigator.of(context).popUntil((route) => route.isFirst);
            context.read<AppNavigationCubit>().setIndex(0);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  /// ------------------------------
                  /// SliverAppBar animato con header lega
                  /// ------------------------------
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

                  /// ------------------------------
                  /// SliverToBoxAdapter con selezione e creazione torneo
                  /// ------------------------------
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.lg,
                        vertical: ThemeSizes.md,
                      ),
                      child: Column(
                        children: [
                          InfoBanner(
                            message:
                                "Unisciti a una squadra esistente o creane una nuova per partecipare alla lega",
                            color: ColorPalette.warning,
                          ),
                          const SizedBox(height: ThemeSizes.xl),
                          if (widget.league.participants.isNotEmpty)
                            _buildExistingTeamsCard(isJoiningTeam),
                          const SizedBox(height: ThemeSizes.lg),
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

  /// ------------------------------
  /// _buildLeagueHeader: header con parallax e gradient
  /// ------------------------------
  Widget _buildLeagueHeader() {
    final appThemeCubit = context.read<AppThemeCubit>();
    final appThemeState = appThemeCubit.state;

    return Stack(
      fit: StackFit.expand,
      children: [
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
                Hero(
                  tag: 'league_icon_${widget.league.id}',
                  child: Container(
                    width: 90,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
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
                Text(
                  widget.league.name,
                  style: context.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.league.description != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.xs,
                      vertical: ThemeSizes.xs,
                    ),
                    child: Text(
                      widget.league.description!,
                      style: context.textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: ThemeSizes.xl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.md,
                    vertical: ThemeSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: appThemeState.themeMode == ThemeMode.light
                        ? ColorPalette.bgColor(ThemeMode.dark)
                            .withValues(alpha: 0.8)
                        : ColorPalette.bgColor(ThemeMode.light)
                            .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_rounded,
                          color: appThemeState.themeMode == ThemeMode.light
                              ? ColorPalette.textPrimary(ThemeMode.dark)
                              : ColorPalette.textPrimary(ThemeMode.light),
                          size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Lega a Squadre',
                        style: context.textTheme.labelMedium!.copyWith(
                          color: appThemeState.themeMode == ThemeMode.light
                              ? ColorPalette.textPrimary(ThemeMode.dark)
                              : ColorPalette.textPrimary(ThemeMode.light),
                        ),
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

  /// ------------------------------
  /// _buildExistingTeamsCard: visualizza lista squadre esistenti e bottone
  /// ------------------------------
  Widget _buildExistingTeamsCard(bool isJoiningTeam) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.groups, color: context.primaryColor, size: 20),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Squadre Esistenti',
                        style: context.textTheme.bodyLarge!.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('Seleziona una squadra per unirti'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 1,
            color: ColorPalette.darkGrey.withValues(alpha: 0.1),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: _buildTeamsList(),
          ),
          // pulsante unisciti
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: ElevatedButton(
              onPressed: _selectedTeamIndex != null && !isJoiningTeam
                  ? () => _joinExistingTeam(_selectedTeamIndex!)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
              ),
              child: isJoiningTeam
                  ? const Loader(color: Colors.white)
                  : const Text('Unisciti alla squadra'),
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------
  /// _buildCreateTeamCard: form per nome nuova squadra e bottone crea
  /// ------------------------------
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header crea squadra
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: ColorPalette.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_circle_outline,
                      color: ColorPalette.warning, size: 20),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crea una Nuova Squadra',
                        style: context.textTheme.bodyLarge!.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('Diventa capitano!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 1,
            color: ColorPalette.darkGrey.withValues(alpha: 0.1),
          ),
          // campo nome squadra e bottone crea
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome della Squadra'),
                const SizedBox(height: ThemeSizes.sm),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    hintText: 'Los chiavadores...',
                    fillColor: context.bgColor,
                    prefixIcon: Icon(
                      Icons.group_add,
                      color: _teamNameController.text.isEmpty
                          ? context.textSecondaryColor
                          : ColorPalette.warning,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: ThemeSizes.md, horizontal: ThemeSizes.sm),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: ThemeSizes.md),
                ElevatedButton(
                  onPressed: canCreateTeam ? _createNewTeam : null,
                  style: context.elevatedButtonThemeData.style!.copyWith(
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: ThemeSizes.md)),
                    backgroundColor: WidgetStatePropertyAll(
                        ColorPalette.warning.withValues(alpha: 0.60)),
                    foregroundColor: const WidgetStatePropertyAll(Colors.white),
                    elevation: const WidgetStatePropertyAll(0),
                    fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(Constants.getWidth(context) * 0.8)),
                  ),
                  child: isCreatingTeam
                      ? const Loader(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add),
                            SizedBox(width: ThemeSizes.sm),
                            Text('Crea nuova squadra'),
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

  /// ------------------------------
  /// _buildTeamsList: lista interattiva di team con selezione
  /// ------------------------------
  Widget _buildTeamsList() {
    if (widget.league.participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_outlined,
                  size: 64,
                  color: context.textSecondaryColor.withValues(alpha: 0.3)),
              const SizedBox(height: ThemeSizes.md),
              Text('Nessuna squadra disponibile',
                  style: context.textTheme.titleMedium),
              const SizedBox(height: ThemeSizes.sm),
              Text('Sii il primo a creare una squadra!',
                  style: TextStyle(color: context.textSecondaryColor)),
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
        color: context.borderColor.withValues(alpha: 0.1),
        indent: ThemeSizes.lg,
        endIndent: ThemeSizes.lg,
      ),
      itemBuilder: (context, index) {
        final participant = widget.league.participants[index];
        if (participant is TeamParticipant) {
          final isSelected = _selectedTeamIndex == index;
          return InkWell(
            onTap: () => setState(() {
              _selectedTeamIndex = isSelected ? null : index;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              margin: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.xs, vertical: ThemeSizes.xs),
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Row(
                  children: [
                    // icona squadra con stato animato
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.primaryColor.withValues(alpha: 0.2)
                            : context.primaryColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.group_rounded,
                            color: isSelected
                                ? context.primaryColor
                                : context.primaryColor.withValues(alpha: 0.5),
                            size: 26),
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),
                    // dettagli squadra
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(participant.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: context.textPrimaryColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 14, color: context.textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                '${participant.userIds.length} ${participant.userIds.length == 1 ? 'membro' : 'membri'}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: context.textSecondaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // indicatore di selezione
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
                              : context.textSecondaryColor
                                  .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
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
