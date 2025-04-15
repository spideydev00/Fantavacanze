import 'package:fantavacanze_official/core/constants/game_mode.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/create-league/basic_info_step.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/create-league/team_type_step.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/create-league/rules_step.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rule_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/league_created_page.dart';

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
  GameMode _selectedRuleMode = GameMode.hot;
  bool _isLoadingRules = false;
  bool _rulesLoaded = false;

  final ScrollController _scrollController = ScrollController();
  bool _areButtonsVisible = true;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    // Load hot mode rules by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredefinedRules("hard");
    });

    // Add scroll listener
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_currentStep == 2) {
      if (_scrollController.position.isScrollingNotifier.value) {
        if (_areButtonsVisible) {
          setState(() {
            _areButtonsVisible = false;
            _isScrolling = true;
          });
        }
      } else if (_isScrolling) {
        _isScrolling = false;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_isScrolling && mounted) {
            setState(() {
              _areButtonsVisible = true;
            });
          }
        });
      }
    }
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha(153),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return RuleDialog(
          title: 'Aggiungi Regola',
          buttonText: 'Aggiungi',
          onSave: (name, type, points) {
            setState(() {
              final newRule = {
                'id': _rules.isEmpty ? 1 : _rules.length + 1,
                'name': name,
                'type': type.toString().split('.').last,
                'points': points,
              };

              if (type == RuleType.bonus) {
                int lastBonusIndex = -1;
                for (int i = 0; i < _rules.length; i++) {
                  if (_rules[i]['type'] == 'bonus') {
                    lastBonusIndex = i;
                  }
                }

                if (lastBonusIndex >= 0) {
                  _rules.insert(lastBonusIndex + 1, newRule);
                } else {
                  _rules.insert(0, newRule);
                }
              } else {
                _rules.add(newRule);
              }

              _updateRuleIds();
            });
          },
        );
      },
    );
  }

  void _editRule(int index) {
    final rule = _rules[index];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha(153),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return RuleDialog(
          title: 'Modifica Regola',
          buttonText: 'Salva',
          initialRule: rule,
          onSave: (name, type, points) {
            setState(() {
              _rules[index] = {
                'id': rule['id'],
                'name': name,
                'type': type.toString().split('.').last,
                'points': points,
              };
            });
          },
        );
      },
    );
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
      _updateRuleIds();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_rules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aggiungi almeno una regola'),
            backgroundColor: ColorPalette.warning,
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

  void _handleRuleModeChanged(GameMode mode) {
    setState(() {
      _selectedRuleMode = mode;
      _rules = [];
      _rulesLoaded = false;
    });

    if (mode == GameMode.hot) {
      _loadPredefinedRules("hard");
    } else if (mode == GameMode.soft) {
      _loadPredefinedRules("soft");
    } else {
      setState(() {
        _rulesLoaded = true;
      });
    }
  }

  void _onStepTapped(int step) {
    // Only allow navigation to steps that we've already visited or the next step
    if (step <= _currentStep || step == _currentStep + 1) {
      // Validate current step if moving forward
      if (_currentStep == 0 && step > 0) {
        // Validate basic info step
        if (_nameController.text.trim().isEmpty ||
            _descriptionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compila tutti i campi obbligatori'),
              backgroundColor: ColorPalette.warning,
            ),
          );
          return;
        }
      }

      setState(() {
        _currentStep = step;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Lega'),
        elevation: 0,
        leading: BackButton(
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: BlocListener<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueCreated) {
            // Navigate to the league created page instead of just popping
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LeagueCreatedPage(
                  league: state.league,
                ),
              ),
            );
          } else if (state is LeagueError) {
            setState(() {
              _isCreating = false;
              _isLoadingRules = false;
            });
            showSnackBar(context, state.message);
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
        child: Column(
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: context.secondaryBgColor,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        surface: context.secondaryBgColor,
                      ),
                ),
                child: Stepper(
                  margin: EdgeInsets.zero,
                  type: StepperType.horizontal,
                  connectorThickness: 0,
                  elevation: 0,
                  currentStep: _currentStep,
                  onStepTapped: _onStepTapped,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      if (_currentStep == 0) {
                        if (_nameController.text.trim().isEmpty) {
                          showSnackBar(
                              context, "Compila tutti i campi obbligatori!");
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
                      title: Text(
                        'Informazioni',
                        style: context.textTheme.labelLarge,
                      ),
                      content: BasicInfoStep(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        formKey: _formKey,
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : (_currentStep == 0
                              ? StepState.editing
                              : StepState.indexed),
                    ),
                    Step(
                      title: Text('Tipo', style: context.textTheme.labelLarge),
                      content: TeamTypeStep(
                        isTeamBased: _isTeamBased,
                        onTeamTypeChanged: (value) {
                          setState(() {
                            _isTeamBased = value;
                          });
                        },
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : (_currentStep == 1
                              ? StepState.editing
                              : StepState.indexed),
                    ),
                    Step(
                      title:
                          Text('Regole', style: context.textTheme.labelLarge),
                      content: RulesStep(
                        scrollController: _scrollController,
                        selectedRuleMode: _selectedRuleMode,
                        isLoadingRules: _isLoadingRules,
                        rulesLoaded: _rulesLoaded,
                        rules: _rules,
                        onRuleModeChanged: _handleRuleModeChanged,
                        onAddRule: _addRule,
                        onEditRule: _editRule,
                        onRemoveRule: _removeRule,
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep == 2
                          ? StepState.editing
                          : StepState.indexed,
                    ),
                  ],
                  controlsBuilder: (context, details) {
                    if (_currentStep == 2) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: ThemeSizes.lg),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              flex: 3,
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Indietro'),
                              ),
                            ),
                          if (_currentStep > 0)
                            const SizedBox(width: ThemeSizes.sm),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed:
                                  _isCreating ? null : details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                fixedSize: null,
                                padding: const EdgeInsets.symmetric(
                                  vertical: ThemeSizes.md,
                                  horizontal: ThemeSizes.sm,
                                ),
                              ),
                              child: Text(
                                _isCreating
                                    ? 'Creazione in corso...'
                                    : _currentStep < 2
                                        ? 'Continua'
                                        : 'Crea Lega',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_currentStep == 2)
              AnimatedOpacity(
                opacity: _areButtonsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _areButtonsVisible ? 80 : 0,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : ThemeSizes.md,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.md,
                    vertical: ThemeSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.bgColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          child: const Text('Indietro'),
                        ),
                      ),
                      const SizedBox(width: ThemeSizes.sm),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: _isCreating ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            fixedSize: null,
                            padding: const EdgeInsets.symmetric(
                              vertical: ThemeSizes.md,
                              horizontal: ThemeSizes.sm,
                            ),
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          child: Text(
                            _isCreating ? 'Creazione in corso...' : 'Crea Lega',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
