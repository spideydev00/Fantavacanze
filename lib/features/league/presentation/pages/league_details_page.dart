import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/event_list_item.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/memory_item.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/participant_item.dart';
import 'package:intl/intl.dart';

class LeagueDetailsPage extends StatefulWidget {
  final String leagueId;

  const LeagueDetailsPage({super.key, required this.leagueId});

  @override
  State<LeagueDetailsPage> createState() => _LeagueDetailsPageState();
}

class _LeagueDetailsPageState extends State<LeagueDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<LeagueBloc>().add(GetLeagueEvent(leagueId: widget.leagueId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'achievement';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Event Name',
                        hintText: 'e.g., Morning Run',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'achievement',
                          child: Text('Achievement'),
                        ),
                        DropdownMenuItem(
                          value: 'challenge',
                          child: Text('Challenge'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Custom'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Points',
                        hintText: 'e.g., 10',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Describe the event...',
                      ),
                      maxLines: 3,
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
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pointsText = pointsController.text.trim();
                    final description = descriptionController.text.trim();

                    if (name.isNotEmpty && pointsText.isNotEmpty) {
                      final points = int.tryParse(pointsText) ?? 0;

                      // Add event through bloc
                      context.read<LeagueBloc>().add(
                            AddEventEvent(
                              leagueId: widget.leagueId,
                              name: name,
                              points: points,
                              eventType: selectedType,
                              description:
                                  description.isNotEmpty ? description : null,
                            ),
                          );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMemoryDialog(BuildContext context, List<Event> events) {
    final textController = TextEditingController();
    String? selectedEventId;
    // Mock image URL for demo purposes, in a real app you'd use an image picker
    final String mockImageUrl = 'https://via.placeholder.com/300';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Memory'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        labelText: 'Memory Text',
                        hintText: 'Write about this memory...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    if (events.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedEventId,
                        decoration: const InputDecoration(
                          labelText: 'Related Event (Optional)',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...events.map((e) => DropdownMenuItem<String>(
                                value: e.id,
                                child: Text(e.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedEventId = value;
                          });
                        },
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
                ElevatedButton(
                  onPressed: () {
                    final text = textController.text.trim();

                    if (text.isNotEmpty) {
                      // Add memory through bloc
                      context.read<LeagueBloc>().add(
                            AddMemoryEvent(
                              leagueId: widget.leagueId,
                              imageUrl: mockImageUrl,
                              text: text,
                              relatedEventId: selectedEventId,
                            ),
                          );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LeagueBloc, LeagueState>(
          builder: (context, state) {
            if (state is LeagueLoaded) {
              return Text(state.league.name);
            }
            return const Text('League Details');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Events'),
            Tab(text: 'Memories'),
          ],
        ),
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
          } else if (state is EventAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh league details
            context
                .read<LeagueBloc>()
                .add(GetLeagueEvent(leagueId: widget.leagueId));
          } else if (state is MemoryAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Memory added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh league details
            context
                .read<LeagueBloc>()
                .add(GetLeagueEvent(leagueId: widget.leagueId));
          }
        },
        builder: (context, state) {
          if (state is LeagueLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is LeagueLoaded ||
              state is EventAdded ||
              state is MemoryAdded) {
            final League league;
            if (state is LeagueLoaded) {
              league = state.league;
            } else if (state is EventAdded) {
              league = state.league;
            } else if (state is MemoryAdded) {
              league = state.league;
            } else {
              // This should never happen, but we need to handle it
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(context, league),

                // Events Tab
                _buildEventsTab(context, league.events),

                // Memories Tab
                _buildMemoriesTab(context, league.memories, league.events),
              ],
            );
          }

          return const Center(
            child: Text('No league data found'),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, League league) {
    final formatter = DateFormat('MMMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'League Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    league.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text('Created on: ${formatter.format(league.createdAt)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text(
                          'Type: ${league.isTeamBased ? 'Team-based' : 'Individual'}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rules',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (league.rules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No rules defined for this league.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: league.rules.length,
              itemBuilder: (context, index) {
                final rule = league.rules[index];
                final isBonus = rule.type == RuleType.bonus;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(rule.name),
                    subtitle: Text(
                      '${isBonus ? '+' : '-'}${rule.points} points',
                    ),
                    leading: Icon(
                      isBonus ? Icons.add_circle : Icons.remove_circle,
                      color: isBonus ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Text(
            'Participants',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (league.participants.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No participants have joined this league yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: league.participants.length,
              itemBuilder: (context, index) {
                final participant = league.participants[index];
                return ParticipantItem(participant: participant);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(BuildContext context, List<Event> events) {
    return Stack(
      children: [
        if (events.isEmpty)
          const Center(
            child: Text('No events yet. Add your first event!'),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventListItem(event: events[index]);
            },
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddEventDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoriesTab(
      BuildContext context, List<Memory> memories, List<Event> events) {
    return Stack(
      children: [
        if (memories.isEmpty)
          const Center(
            child: Text('No memories yet. Add your first memory!'),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              return MemoryItem(memory: memories[index]);
            },
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddMemoryDialog(context, events),
            child: const Icon(Icons.photo_camera),
          ),
        ),
      ],
    );
  }
}
