import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/league_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/league_details_page.dart';

class LeaguePage extends StatefulWidget {
  const LeaguePage({super.key});

  @override
  State<LeaguePage> createState() => _LeaguePageState();
}

class _LeaguePageState extends State<LeaguePage> {
  @override
  void initState() {
    super.initState();
    context.read<LeagueBloc>().add(const GetUserLeaguesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leagues'),
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
          } else if (state is LeagueJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined the league!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the list
            context.read<LeagueBloc>().add(const GetUserLeaguesEvent());
          } else if (state is LeagueCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('League created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the list
            context.read<LeagueBloc>().add(const GetUserLeaguesEvent());
          } else if (state is MultiplePossibleLeagues) {
            // Show dialog to let user select which league to join
            _showLeagueSelectionDialog(
              context,
              state.inviteCode,
              state.possibleLeagues,
            );
          }
        },
        builder: (context, state) {
          if (state is LeagueLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserLeaguesLoaded) {
            final leagues = state.leagues;

            if (leagues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You are not part of any leagues yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateLeaguePage(),
                          ),
                        );
                      },
                      child: const Text('Create a League'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _showJoinLeagueDialog(context);
                      },
                      child: const Text('Join a League'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leagues.length,
              itemBuilder: (context, index) {
                final league = leagues[index];
                return LeagueCard(
                  league: league,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeagueDetailsPage(
                          leagueId: league.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          // Default or initial state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to your Leagues'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLeaguePage(),
                      ),
                    );
                  },
                  child: const Text('Create a League'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    _showJoinLeagueDialog(context);
                  },
                  child: const Text('Join a League'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLeaguePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showJoinLeagueDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join a League'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter invite code',
                  labelText: 'Invite Code',
                  prefixIcon: Icon(Icons.group_add),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ask the league creator for the 10-character invite code.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  context.read<LeagueBloc>().add(
                        JoinLeagueEvent(
                          inviteCode: code,
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void _showLeagueSelectionDialog(
      BuildContext context, String inviteCode, List<dynamic> leagues) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Multiple Leagues Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Multiple leagues were found with this invite code. Please select which one you would like to join:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: leagues.map<Widget>((league) {
                      return ListTile(
                        title: Text(league['name']),
                        subtitle: Text(
                          league['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // Join the selected league
                          context.read<LeagueBloc>().add(
                                JoinLeagueEvent(
                                  inviteCode: inviteCode,
                                  specificLeagueId: league['id'],
                                ),
                              );
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
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
