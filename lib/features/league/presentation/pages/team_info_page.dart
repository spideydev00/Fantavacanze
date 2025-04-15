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
        if (state is AppLeagueExists && state.selectedLeague != null) {
          final league = state.selectedLeague!;
          final userState = context.read<AppUserCubit>().state;

          if (userState is! AppUserIsLoggedIn) {
            return const Center(child: Text('Utente non autenticato'));
          }

          final userId = userState.user.id;
          final isAdmin = context.read<AppLeagueCubit>().isAdmin();

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

class _TeamBasedInfoState extends State<_TeamBasedInfo> {
  final _teamNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team.name;
  }

  @override
  void dispose() {
    _teamNameController.dispose();
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
            leagueId: widget.league.id,
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
      appBar: AppBar(
        title: const Text('Info Squadra'),
        actions: [
          if (canEdit && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateTeamName,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEdit,
            ),
        ],
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
                      Icons.group,
                      size: 64,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  if (_isEditing) ...[
                    TextField(
                      controller: _teamNameController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Nome della squadra',
                        labelText: 'Nome Squadra',
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      widget.team.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: ThemeSizes.sm),
                  Text(
                    '$members membri',
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
              value: widget.team.points.toInt().toString(),
              icon: Icons.leaderboard,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    label: 'Bonus Totali',
                    value: '+${widget.team.bonusTotal}',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: _StatisticCard(
                    label: 'Malus Totali',
                    value: '-${widget.team.malusTotal}',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.xl),
            const Text(
              'Membri del Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            const Text(
              'Da implementare: Lista dei membri del team con avatar e nome',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            // In a real implementation, you would fetch and display team members here
            const SizedBox(height: ThemeSizes.xxl),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logic to leave team/league
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
                                    leagueId: widget.league.id,
                                    userId: widget.userId,
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
        ),
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
            // In a real implementation, you would fetch and display player events here
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
                                      leagueId: league.id,
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
