import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';

enum RuleMode {
  hot,
  soft,
  custom,
}

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
  List<Map<String, dynamic>> _rules = [];
  bool _isCreating = false;
  int _currentStep = 0;
  RuleMode _selectedRuleMode = RuleMode.hot;
  bool _isLoadingRules = false;
  bool _rulesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load hot mode rules by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredefinedRules("hard");
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadPredefinedRules(String mode) {
    setState(() {
      _isLoadingRules = true;
      _rulesLoaded = false;
    });

    context.read<LeagueBloc>().add(GetRulesEvent(mode: mode));
  }

  void _updateRuleIds() {
    for (int i = 0; i < _rules.length; i++) {
      _rules[i]['id'] = i + 1;
    }
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
              title: const Text('Aggiungi Regola'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Regola',
                      hintText: 'es. Goal Segnato',
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  DropdownButtonFormField<RuleType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo Regola',
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
                  const SizedBox(height: ThemeSizes.md),
                  TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Punti',
                      hintText: 'es. 10',
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
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pointsText = pointsController.text.trim();

                    if (name.isNotEmpty && pointsText.isNotEmpty) {
                      final points = int.tryParse(pointsText) ?? 0;

                      setState(() {
                        _rules.add({
                          'id': _rules.isEmpty ? 1 : _rules.length + 1,
                          'name': name,
                          'type': selectedType.toString().split('.').last,
                          'points': points,
                        });
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _editRule(int index) {
    final rule = _rules[index];
    final nameController = TextEditingController(text: rule['name']);
    final pointsController =
        TextEditingController(text: rule['points'].toString());
    RuleType selectedType =
        rule['type'] == 'bonus' ? RuleType.bonus : RuleType.malus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifica Regola'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Regola',
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  DropdownButtonFormField<RuleType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo Regola',
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
                  const SizedBox(height: ThemeSizes.md),
                  TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Punti',
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
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pointsText = pointsController.text.trim();

                    if (name.isNotEmpty && pointsText.isNotEmpty) {
                      final points = int.tryParse(pointsText) ?? 0;

                      setState(() {
                        _rules[index] = {
                          'id': rule['id'],
                          'name': name,
                          'type': selectedType.toString().split('.').last,
                          'points': points,
                        };
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
      _updateRuleIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Lega'),
        elevation: 0,
      ),
      body: BlocListener<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueCreated) {
            Navigator.pop(context);
          } else if (state is LeagueError) {
            setState(() {
              _isCreating = false;
              _isLoadingRules = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RulesLoaded) {
            setState(() {
              _isLoadingRules = false;
              _rulesLoaded = true;

              _rules = state.rules
                  .map((rule) => {
                        'id': rule.id,
                        'name': rule.name,
                        'type': rule.type.toString().split('.').last,
                        'points': rule.points,
                      })
                  .toList();

              _updateRuleIds();
            });
          }
        },
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              if (_currentStep == 0) {
                if (_nameController.text.trim().isEmpty ||
                    _descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compila tutti i campi obbligatori'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
              }
              setState(() {
                _currentStep++;
              });
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            Step(
              title: const Text('Informazioni'),
              content: _buildBasicInfoStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Tipo'),
              content: _buildTeamTypeStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Regole'),
              content: _buildRulesStep(),
              isActive: _currentStep >= 2,
            ),
          ],
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: ThemeSizes.lg),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColor,
                          side: BorderSide(color: context.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeSizes.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ThemeSizes.buttonRadius),
                          ),
                        ),
                        child: const Text('Indietro'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : details.onStepContinue,
                      child: Text(_isCreating
                          ? 'Creazione in corso...'
                          : _currentStep < 2
                              ? 'Continua'
                              : 'Crea Lega'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informazioni di Base',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          Container(
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                  floatingLabelStyle: TextStyle(color: Colors.white),
                ),
              ),
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Nome Lega',
                  hintText: 'es. Vacanza Estate 2023',
                  prefixIcon: Icon(Icons.title, color: context.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.secondaryBgColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un nome per la tua lega';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          Container(
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                  floatingLabelStyle: TextStyle(color: Colors.white),
                ),
              ),
              child: TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Motto',
                  hintText: 'Hai un motto? Scrivilo qui!',
                  prefixIcon:
                      Icon(Icons.description, color: context.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.secondaryBgColor,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo di Lega',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        Container(
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.primaryColor;
                  }
                  return Colors.grey;
                }),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Lega Individuale'),
                    subtitle:
                        const Text('I partecipanti competono individualmente'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _isTeamBased,
                      onChanged: (value) {
                        setState(() {
                          _isTeamBased = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Lega a Squadre'),
                    subtitle: const Text('I partecipanti competono in squadre'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _isTeamBased,
                      onChanged: (value) {
                        setState(() {
                          _isTeamBased = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: ThemeSizes.lg),
        Container(
          padding: const EdgeInsets.all(ThemeSizes.md),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.primaryColor,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  _isTeamBased
                      ? 'In una lega a squadre, i partecipanti possono unirsi a squadre e competere insieme.'
                      : 'In una lega individuale, ogni partecipante compete per sé stesso.',
                  style: TextStyle(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modalità Regole',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        Container(
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.primaryColor;
                  }
                  return Colors.grey;
                }),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Hot Mode'),
                    subtitle:
                        const Text('Regole predefinite per vacanze intensive'),
                    leading: Radio<RuleMode>(
                      value: RuleMode.hot,
                      groupValue: _selectedRuleMode,
                      onChanged: _isLoadingRules
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRuleMode = value!;
                                _rules = [];
                                _rulesLoaded = false;
                              });
                              _loadPredefinedRules("hard");
                            },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Soft Mode'),
                    subtitle:
                        const Text('Regole predefinite per vacanze tranquille'),
                    leading: Radio<RuleMode>(
                      value: RuleMode.soft,
                      groupValue: _selectedRuleMode,
                      onChanged: _isLoadingRules
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRuleMode = value!;
                                _rules = [];
                                _rulesLoaded = false;
                              });
                              _loadPredefinedRules("soft");
                            },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Completamente Personalizzata'),
                    subtitle: const Text('Crea tutte le regole da zero'),
                    leading: Radio<RuleMode>(
                      value: RuleMode.custom,
                      groupValue: _selectedRuleMode,
                      onChanged: _isLoadingRules
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRuleMode = value!;
                                _rules = [];
                                _rulesLoaded = true;
                              });
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: ThemeSizes.lg),
        if (_isLoadingRules)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: context.primaryColor),
                const SizedBox(height: ThemeSizes.md),
                Text(
                  'Caricamento regole...',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else if (_rulesLoaded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Regole della Lega',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _addRule,
                    icon: Icon(
                      Icons.add_circle,
                      color: context.primaryColor,
                    ),
                    tooltip: 'Aggiungi Regola',
                  ),
                ],
              ),
              const SizedBox(height: ThemeSizes.sm),
              if (_rules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ThemeSizes.lg),
                  decoration: BoxDecoration(
                    color: context.secondaryBgColor,
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    border: Border.all(
                      color: context.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rule,
                        size: 48,
                        color:
                            context.textSecondaryColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: ThemeSizes.md),
                      Text(
                        'Nessuna regola aggiunta',
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeSizes.sm),
                      Text(
                        'Clicca sul pulsante + per aggiungere regole alla tua lega.',
                        style: TextStyle(
                          color: context.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
                      color: isBonus
                          ? Colors.green.withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        side: BorderSide(
                          color: isBonus
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          rule['name'],
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${isBonus ? '+' : '-'}${rule['points'].toInt()} punti',
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isBonus
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          child: Icon(
                            isBonus ? Icons.add_circle : Icons.remove_circle,
                            color: isBonus ? Colors.green : Colors.red,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.edit, color: context.primaryColor),
                              onPressed: () => _editRule(index),
                              tooltip: 'Modifica regola',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: context.primaryColor
                                      .withValues(alpha: 0.7)),
                              onPressed: () => _removeRule(index),
                              tooltip: 'Rimuovi regola',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: ThemeSizes.md),
              if (_rules.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                  child: ElevatedButton.icon(
                    onPressed: _addRule,
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi Prima Regola'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.lg,
                        vertical: ThemeSizes.sm,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_rules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aggiungi almeno una regola'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isCreating = true;
      });

      context.read<LeagueBloc>().add(
            CreateLeagueEvent(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              isTeamBased: _isTeamBased,
              rules: _rules,
            ),
          );
    }
  }
}
