import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum JoiningAction {
  none,
  searching,
  joiningTeam,
  creatingTeam,
}

class JoinLeaguePage extends StatefulWidget {
  const JoinLeaguePage({super.key});

  @override
  State<JoinLeaguePage> createState() => _JoinLeaguePageState();
}

class _JoinLeaguePageState extends State<JoinLeaguePage> {
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  JoiningAction _joiningAction = JoiningAction.none;
  String? _userId;

  League? _currentLeague;
  int? _selectedTeamIndex;
  String? _currentInviteCode;

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
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  // Search for a league with the provided invite code
  void _searchLeague() {
    if (_inviteCodeController.text.isEmpty || _userId == null) return;

    setState(() {
      _joiningAction = JoiningAction.searching;
      _currentInviteCode = _inviteCodeController.text;
    });

    context.read<LeagueBloc>().add(
          JoinLeagueEvent(
            inviteCode: _inviteCodeController.text,
          ),
        );
  }

  // Join a league (either directly for individual leagues or after selecting/creating a team)
  void _joinLeague({
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) {
    if (_userId == null) return;

    setState(() => _joiningAction = JoiningAction.joiningTeam);

    context.read<LeagueBloc>().add(
          JoinLeagueEvent(
            inviteCode: _currentInviteCode ?? _inviteCodeController.text,
            teamName: teamName,
            teamMembers: teamMembers,
            specificLeagueId: specificLeagueId,
          ),
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

  // Join an existing team
  void _joinExistingTeam(int teamIndex) {
    if (_userId == null || _currentLeague == null) return;

    setState(() => _joiningAction = JoiningAction.joiningTeam);

    final team = _currentLeague!.participants[teamIndex] as TeamParticipant;
    List<String> updatedMembers = [...team.userIds, _userId!];

    _joinLeague(
      teamName: team.name,
      teamMembers: updatedMembers,
      specificLeagueId: _currentLeague!.id,
    );
  }

  // Show confirmation dialog for joining an individual league
  void _showJoinLeagueConfirmation(BuildContext context, League league) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.joinLeague(
        leagueName: league.name,
        onJoin: () => _joinLeague(specificLeagueId: league.id),
      ),
    );
  }

  // Show dialog for selecting between multiple leagues with the same invite code
  void _showMultipleLeaguesDialog(
    List<dynamic> possibleLeagues,
    String inviteCode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona una Lega'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: possibleLeagues.length,
            itemBuilder: (context, index) {
              final league = possibleLeagues[index];
              return ListTile(
                title: Text(league['name']),
                subtitle: Text(league['description'] ?? 'Nessuna descrizione'),
                onTap: () {
                  Navigator.pop(context);
                  // Search for the specific league
                  context.read<LeagueBloc>().add(
                        JoinLeagueEvent(
                          inviteCode: inviteCode,
                          specificLeagueId: league['id'],
                        ),
                      );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Unisciti a una Lega', style: context.textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _joiningAction = JoiningAction.none);
          } else if (state is LeagueSuccess &&
              state.operation == 'join_league') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('Unione completata'),
                content: Text(
                    'Ti sei unito con successo alla lega ${state.league.name}'),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Ok'),
                  ),
                ],
              ),
            );
          } else if (state is MultiplePossibleLeagues) {
            setState(() => _joiningAction = JoiningAction.none);
            _showMultipleLeaguesDialog(state.possibleLeagues, state.inviteCode);
          } else if (state is LeagueWithInviteCode) {
            setState(() {
              _joiningAction = JoiningAction.none;
              _currentLeague = state.league;
              _currentInviteCode = state.inviteCode;
            });

            // For individual leagues, just show confirmation dialog
            if (!state.league.isTeamBased) {
              _showJoinLeagueConfirmation(context, state.league);
            }
            // For team-based leagues, the UI will update to show team options
          }
        },
        builder: (context, state) {
          // If we have a team-based league to display
          if (_currentLeague != null && _currentLeague!.isTeamBased) {
            return _buildTeamBasedLeagueView(_currentLeague!);
          }

          // Otherwise show the search view
          return _buildSearchView();
        },
      ),
    );
  }

  Widget _buildSearchView() {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      margin: const EdgeInsets.all(ThemeSizes.lg),
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Inserisci il codice di invito per unirti a una lega',
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.xl),
          TextField(
            controller: _inviteCodeController,
            decoration: InputDecoration(
              labelText: 'Codice Invito',
              hintText: 'Inserisci il codice di invito',
              prefixIcon: const Icon(Icons.code),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(ThemeSizes.borderRadiusMd),
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _searchLeague(),
          ),
          const SizedBox(height: ThemeSizes.xl),
          ElevatedButton(
            onPressed: _joiningAction == JoiningAction.searching
                ? null
                : _searchLeague,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              ),
            ),
            child: _joiningAction == JoiningAction.searching
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Cerca Lega'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBasedLeagueView(League league) {
    final bool isJoiningTeam = _joiningAction == JoiningAction.joiningTeam;
    final bool isCreatingTeam = _joiningAction == JoiningAction.creatingTeam;

    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // League header card
          Container(
            padding: const EdgeInsets.all(ThemeSizes.md),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Lega a squadre: ${league.name}',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (league.description != null) ...[
                  const SizedBox(height: ThemeSizes.sm),
                  Text(
                    league.description!,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ThemeSizes.lg),

          // Existing teams section
          if (league.participants.isNotEmpty) ...[
            Text('Unisciti a una squadra esistente',
                style: context.textTheme.titleMedium),
            const SizedBox(height: ThemeSizes.sm),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          context.colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: ListView.separated(
                  itemCount: league.participants.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final participant = league.participants[index];
                    if (participant is TeamParticipant) {
                      return Material(
                        color: _selectedTeamIndex == index
                            ? context.colorScheme.primaryContainer
                            : Colors.transparent,
                        child: ListTile(
                          leading: participant.teamLogoUrl != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(participant.teamLogoUrl!),
                                )
                              : CircleAvatar(
                                  backgroundColor: context.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  child: Text(participant.name.substring(0, 1)),
                                ),
                          title: Text(participant.name),
                          subtitle:
                              Text('${participant.userIds.length} membri'),
                          trailing: Radio<int>(
                            value: index,
                            groupValue: _selectedTeamIndex,
                            onChanged: (value) {
                              setState(() {
                                _selectedTeamIndex = value;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTeamIndex = index;
                            });
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            ElevatedButton(
              onPressed: (_selectedTeamIndex != null &&
                      !isJoiningTeam &&
                      !isCreatingTeam)
                  ? () => _joinExistingTeam(_selectedTeamIndex!)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                ),
              ),
              child: isJoiningTeam
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Unisciti alla squadra selezionata'),
            ),
            const SizedBox(height: ThemeSizes.lg),
          ],

          // Divider
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          const SizedBox(height: ThemeSizes.md),

          // Create new team section
          Container(
            padding: const EdgeInsets.all(ThemeSizes.md),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              border: Border.all(
                  color: context.colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Crea una nuova squadra',
                    style: context.textTheme.titleMedium),
                const SizedBox(height: ThemeSizes.md),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome della Squadra',
                    hintText: 'Inserisci il nome della tua nuova squadra',
                    prefixIcon: const Icon(Icons.group),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: ThemeSizes.md),
                ElevatedButton(
                  onPressed: (isJoiningTeam ||
                          isCreatingTeam ||
                          _teamNameController.text.trim().isEmpty)
                      ? null
                      : _createNewTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.secondary,
                    padding:
                        const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    ),
                  ),
                  child: isCreatingTeam
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crea nuova squadra'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
