import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
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

          if (userParticipant == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  const Text(
                    'Non sei ancora un partecipante di questa lega',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: ThemeSizes.lg),
                  ElevatedButton(
                    onPressed: () {
                      // Logic to join the league
                    },
                    child: const Text('Partecipa alla lega'),
                  ),
                ],
              ),
            );
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
                );
        }

        return const Center(child: Text('Nessuna lega selezionata'));
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
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (canEdit && !_isEditing)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.bgColor.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: context.primaryColor,
                  size: 18,
                ),
              ),
              onPressed: _toggleEdit,
            ),
          if (_isEditing)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.bgColor.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              onPressed: _updateTeamName,
            ),
          if (_isEditing)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.bgColor.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 18,
                ),
              ),
              onPressed: _toggleEdit,
            ),
          const SizedBox(width: ThemeSizes.sm),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.bgColor,
              context.secondaryColor.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section with Team Avatar
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.lg),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'team_avatar_${widget.team.name}',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.primaryColor,
                                context.secondaryColor,
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
                          child: Center(
                            child: Icon(
                              Icons.group,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      if (_isEditing) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: context.secondaryBgColor,
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _teamNameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: ThemeSizes.md,
                                vertical: ThemeSizes.sm,
                              ),
                              border: InputBorder.none,
                              hintText: 'Nome della squadra',
                              hintStyle: TextStyle(
                                color: context.textSecondaryColor
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          widget.team.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: ThemeSizes.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.md,
                          vertical: ThemeSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        ),
                        child: Text(
                          '$members membri',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistics section
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    ThemeSizes.lg,
                    ThemeSizes.lg,
                    ThemeSizes.lg,
                    ThemeSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: context.secondaryBgColor,
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ThemeSizes.md),
                        decoration: BoxDecoration(
                          color: context.secondaryBgColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ThemeSizes.borderRadiusLg),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              color: context.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Text(
                              'Statistiche',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: context.borderColor.withValues(alpha: 0.1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(ThemeSizes.md),
                        child: Column(
                          children: [
                            _ModernScoreCard(
                              score: widget.team.points.toInt(),
                              color: context.primaryColor,
                            ),
                            const SizedBox(height: ThemeSizes.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _ModernStatCard(
                                    icon: Icons.arrow_upward_rounded,
                                    label: 'Bonus',
                                    value: '+${widget.team.bonusTotal}',
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: ThemeSizes.md),
                                Expanded(
                                  child: _ModernStatCard(
                                    icon: Icons.arrow_downward_rounded,
                                    label: 'Malus',
                                    value: '-${widget.team.malusTotal}',
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Team Members Section
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    ThemeSizes.lg,
                    ThemeSizes.md,
                    ThemeSizes.lg,
                    ThemeSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: context.secondaryBgColor,
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ThemeSizes.md),
                        decoration: BoxDecoration(
                          color: context.secondaryBgColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ThemeSizes.borderRadiusLg),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: context.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Text(
                              'Membri del Team',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: context.borderColor.withValues(alpha: 0.1),
                      ),
                      Container(
                        padding: const EdgeInsets.all(ThemeSizes.md),
                        child: Text(
                          'Da implementare: Lista dei membri del team con avatar e nome',
                          style: TextStyle(
                            color: context.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Leave League Button
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: ThemeSizes.xl,
                            horizontal: ThemeSizes.lg,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _buildExitConfirmationDialog(context),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusLg),
                              splashColor: Colors.white.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: ThemeSizes.lg,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: ThemeSizes.sm),
                                    Text(
                                      'Lascia la Lega',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExitConfirmationDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeSizes.md),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Lascia la Lega',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Sei sicuro di voler uscire da questa lega? Questa azione non può essere annullata.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        side: BorderSide(color: context.borderColor),
                      ),
                    ),
                    child: Text(
                      'Annulla',
                      style: TextStyle(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LeagueBloc>().add(
                            ExitLeagueEvent(
                              league: widget.league,
                              userId: widget.userId,
                            ),
                          );
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pop(); // Return to previous screen after exiting
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      ),
                    ),
                    child: const Text('Esci'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernScoreCard extends StatelessWidget {
  final int score;
  final Color color;

  const _ModernScoreCard({
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.lg,
        horizontal: ThemeSizes.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Punteggio Totale',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(ThemeSizes.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.leaderboard_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ModernStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndividualInfo extends StatelessWidget {
  final League league;
  final IndividualParticipant participant;
  final bool isAdmin;

  const _IndividualInfo({
    required this.league,
    required this.participant,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AppUserCubit>().state;
    final userId = userState is AppUserIsLoggedIn ? userState.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Giocatore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(ThemeSizes.lg),
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  Text(
                    participant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeSizes.sm),
                  Text(
                    userId == participant.userId
                        ? 'Il tuo account'
                        : 'Altro partecipante',
                    style: TextStyle(
                      color: context.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThemeSizes.xl),
            const Text(
              'Statistiche',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            _StatisticCard(
              label: 'Punteggio Totale',
              value: participant.points.toInt().toString(),
              icon: Icons.leaderboard,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    label: 'Bonus Totali',
                    value: '+${participant.bonusTotal}',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: _StatisticCard(
                    label: 'Malus Totali',
                    value: '-${participant.malusTotal}',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.xl),
            const Text(
              'Ultimi Eventi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            const Text(
              'Da implementare: Lista degli ultimi eventi registrati dal giocatore',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (userId == participant.userId) ...[
              const SizedBox(height: ThemeSizes.xxl),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logic to leave league
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Lascia la Lega'),
                        content: const Text(
                          'Sei sicuro di voler uscire da questa lega? Questa azione non può essere annullata.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annulla'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LeagueBloc>().add(
                                    ExitLeagueEvent(
                                      league: league,
                                      userId: userId,
                                    ),
                                  );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Esci dalla Lega'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Lascia la Lega'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: ThemeSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
