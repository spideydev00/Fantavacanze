import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';

class JoinLeaguePage extends StatefulWidget {
  const JoinLeaguePage({super.key});

  @override
  State<JoinLeaguePage> createState() => _JoinLeaguePageState();
}

class _JoinLeaguePageState extends State<JoinLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _teamNameController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a League'),
      ),
      body: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isJoining = false;
            });
          } else if (state is LeagueJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined the league!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is MultiplePossibleLeagues) {
            setState(() {
              _isJoining = false;
            });
            _showLeagueSelectionDialog(
                context, state.inviteCode, state.possibleLeagues);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the 10-character invite code',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask the league creator for the invite code to join their league.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'Enter the 10-character code',
                      prefixIcon: const Icon(Icons.code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an invite code';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      // Auto uppercase
                      if (value != value.toUpperCase()) {
                        _inviteCodeController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: _inviteCodeController.selection,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Team (Optional)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If this is a team-based league, you can specify your team name.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _teamNameController,
                    decoration: InputDecoration(
                      labelText: 'Team Name (Optional)',
                      hintText: 'Enter your team name if applicable',
                      prefixIcon: const Icon(Icons.group),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isJoining
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isJoining = true;
                                });
                                final inviteCode =
                                    _inviteCodeController.text.trim();
                                final teamName =
                                    _teamNameController.text.trim();

                                context.read<LeagueBloc>().add(
                                      JoinLeagueEvent(
                                        inviteCode: inviteCode,
                                        teamName: teamName.isNotEmpty
                                            ? teamName
                                            : null,
                                      ),
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isJoining
                          ? const CircularProgressIndicator()
                          : const Text('Join League'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLeagueSelectionDialog(
      BuildContext context, String inviteCode, List<dynamic> leagues) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select League'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiple leagues found with this invite code. Please select which one you want to join:',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: leagues.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final league = leagues[index];
                      return ListTile(
                        title: Text(
                          league['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          league['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final teamName = _teamNameController.text.trim();
                          Navigator.pop(context);
                          setState(() {
                            _isJoining = true;
                          });

                          context.read<LeagueBloc>().add(
                                JoinLeagueEvent(
                                  inviteCode: inviteCode,
                                  teamName:
                                      teamName.isNotEmpty ? teamName : null,
                                  specificLeagueId: league['id'],
                                ),
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
