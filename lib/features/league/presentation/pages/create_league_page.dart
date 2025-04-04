import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';

class CreateLeaguePage extends StatefulWidget {
  const CreateLeaguePage({super.key});

  @override
  State<CreateLeaguePage> createState() => _CreateLeaguePageState();
}

class _CreateLeaguePageState extends State<CreateLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isTeamBased = false;
  final List<Map<String, dynamic>> _rules = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addRule() {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    RuleType selectedType = RuleType.bonus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Rule'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Rule Name',
                      hintText: 'e.g., Goal Scored',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RuleType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Rule Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: RuleType.bonus,
                        child: Text('Bonus'),
                      ),
                      DropdownMenuItem(
                        value: RuleType.malus,
                        child: Text('Malus'),
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
                    final name = nameController.text.trim();
                    final pointsText = pointsController.text.trim();

                    if (name.isNotEmpty && pointsText.isNotEmpty) {
                      final points = int.tryParse(pointsText) ?? 0;

                      setState(() {
                        _rules.add({
                          'name': name,
                          'type': selectedType.toString().split('.').last,
                          'points': points,
                        });
                      });

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
    ).then((_) {
      // Refresh the state
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create League'),
      ),
      body: BlocListener<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueCreated) {
            Navigator.pop(context);
          } else if (state is LeagueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'League Name',
                    hintText: 'e.g., Summer Vacation 2023',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a league name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your league...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Team-based League'),
                  subtitle: Text(
                    _isTeamBased
                        ? 'Participants will compete in teams'
                        : 'Participants will compete individually',
                  ),
                  value: _isTeamBased,
                  onChanged: (value) {
                    setState(() {
                      _isTeamBased = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _addRule,
                      icon: const Icon(Icons.add_circle),
                      tooltip: 'Add Rule',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_rules.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No rules added yet. Tap the + button to add rules.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      final isBonus = rule['type'] == 'bonus';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(rule['name']),
                          subtitle: Text(
                            '${isBonus ? '+' : '-'}${rule['points']} points',
                          ),
                          leading: Icon(
                            isBonus ? Icons.add_circle : Icons.remove_circle,
                            color: isBonus ? Colors.green : Colors.red,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _rules.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Create the league
                        context.read<LeagueBloc>().add(
                              CreateLeagueEvent(
                                name: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                                isTeamBased: _isTeamBased,
                                rules: _rules,
                              ),
                            );
                      }
                    },
                    child: const Text('Create League'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
