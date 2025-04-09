import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/league_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/league_details_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/join_league_page.dart';

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
        title: const Text('Le Mie Leghe'),
        elevation: 0,
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
                content: Text('Lega unita con successo!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the list
            context.read<LeagueBloc>().add(const GetUserLeaguesEvent());
          } else if (state is LeagueCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lega creata con successo!'),
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
                    Icon(
                      Icons.groups_outlined,
                      size: 70,
                      color: context.textSecondaryColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      'Non fai ancora parte di nessuna lega',
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Text(
                      'Crea la tua lega o unisciti ad una esistente',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeSizes.xl),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateLeaguePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Crea una Lega'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.lg,
                          vertical: ThemeSizes.md,
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinLeaguePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('Unisciti ad una Lega'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(ThemeSizes.md),
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
                Icon(
                  Icons.groups_outlined,
                  size: 70,
                  color: context.textSecondaryColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: ThemeSizes.md),
                Text(
                  'Benvenuto nelle tue Leghe',
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: ThemeSizes.xl),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLeaguePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Crea una Lega'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.lg,
                      vertical: ThemeSizes.md,
                    ),
                  ),
                ),
                const SizedBox(height: ThemeSizes.md),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinLeaguePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group_add),
                  label: const Text('Unisciti ad una Lega'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLeaguePage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuova Lega'),
      ),
    );
  }

  void _showLeagueSelectionDialog(
      BuildContext context, String inviteCode, List<dynamic> leagues) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leghe Multiple Trovate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sono state trovate più leghe con questo codice di invito. Seleziona quale vuoi unirti:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: ThemeSizes.md),
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
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
  }
}
