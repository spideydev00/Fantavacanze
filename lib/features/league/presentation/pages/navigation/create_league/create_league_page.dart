import 'package:fantavacanze_official/core/constants/game_mode.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/basic_info_step.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/team_type_step.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/rules_step.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/form_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/league_created_page.dart';
import 'package:fantavacanze_official/core/widgets/rules/type_selector.dart';
import 'package:fantavacanze_official/core/constants/male_rules.dart';
import 'package:fantavacanze_official/core/constants/female_rules.dart';
import 'package:fantavacanze_official/core/constants/mixed_rules.dart';

class CreateLeaguePage extends StatefulWidget {
  static const String routeName = '/create_league';

  static get route => MaterialPageRoute(
        builder: (context) => const CreateLeaguePage(),
        settings: const RouteSettings(name: routeName),
      );

  const CreateLeaguePage({super.key});

  @override
  State<CreateLeaguePage> createState() => _CreateLeaguePageState();
}

class _CreateLeaguePageState extends State<CreateLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isTeamBased = false;
  List<Rule> _rules = [];
  bool _isCreating = false;
  int _currentStep = 0;
  GameMode _selectedRuleMode = GameMode.allTogether;
  bool _isLoadingRules = false;
  bool _rulesLoaded = false;

  // Maps to store rules locally for each mode
  final Map<String, List<Rule>> _cachedRules = {
    'male': [],
    'female': [],
    'mixed': [],
    'custom': [],
  };

  final ScrollController _scrollController = ScrollController();
  bool _areButtonsVisible = true;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    // Load mixed mode rules by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredefinedRules(_selectedRuleMode.apiMode);
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
    // First check if we have cached rules for this mode
    if (_cachedRules.containsKey(mode) && _cachedRules[mode]!.isNotEmpty) {
      setState(() {
        _isLoadingRules = false;
        _rulesLoaded = true;
        _rules = List<Rule>.from(_cachedRules[mode]!);
      });
      return;
    }

    // Set loading state
    setState(() {
      _isLoadingRules = true;
      _rulesLoaded = false;
    });

    // Get rules from local constants instead of database
    List<Rule> localRules = [];

    switch (mode) {
      case 'male':
        localRules = maleRules.map((rule) => rule.toRule()).toList();
        break;
      case 'female':
        localRules = femaleRules.map((rule) => rule.toRule()).toList();
        break;
      case 'mixed':
        localRules = mixedRules.map((rule) => rule.toRule()).toList();
        break;
      case 'custom':
        // Custom rules are empty by default
        localRules = [];
        break;
      default:
        // Default to mixed rules
        localRules = mixedRules.map((rule) => rule.toRule()).toList();
        break;
    }

    // Update state with local rules
    setState(() {
      _isLoadingRules = false;
      _rulesLoaded = true;
      _rules = localRules;
      _cachedRules[mode] = List<Rule>.from(localRules);
    });
  }

  void _addRule() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Annulla',
      barrierColor: Colors.black.withAlpha(153),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return _AddRuleDialog(
          onAdd: (Rule newRule) {
            setState(() {
              if (newRule.type == RuleType.bonus) {
                int lastBonusIndex = -1;
                for (int i = 0; i < _rules.length; i++) {
                  if (_rules[i].type == RuleType.bonus) {
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

              // Update the cache for the current mode
              String currentModeKey = _selectedRuleMode.apiMode;
              _cachedRules[currentModeKey] = List<Rule>.from(_rules);
            });
          },
        );
      },
    );
  }

  void _editRule(int index) {
    final rule = _rules[index];
    final nameController = TextEditingController(text: rule.name);
    final pointsController =
        TextEditingController(text: rule.points.abs().toString());
    final formKey = GlobalKey<FormState>();
    final isBonus = rule.type == RuleType.bonus;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Annulla',
      barrierColor: Colors.black.withAlpha(153),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return FormDialog.ruleForm(
          title: 'Modifica Regola',
          isBonus: isBonus,
          formKey: formKey,
          primaryActionText: 'Salva',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove the duplicate type selectors since we can't change rule type when editing
              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Regola',
                  hintText: 'Inserisci il nome della regola',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              const SizedBox(height: ThemeSizes.md),
              // Points field
              TextField(
                controller: pointsController,
                decoration: InputDecoration(
                  labelText: 'Punti',
                  hintText: 'Valore dei punti',
                  prefixIcon: Icon(
                    Icons.star,
                    color: isBonus ? ColorPalette.success : ColorPalette.error,
                  ),
                  suffixText: 'pt',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          onPrimaryAction: () {
            final name = nameController.text.trim();
            final String pointsText = pointsController.text.trim();

            if (name.isNotEmpty && pointsText.isNotEmpty) {
              double points = double.tryParse(pointsText) ?? 0;

              // For malus rules, make points negative
              if (!isBonus) {
                points = -points.abs();
              }

              setState(() {
                _rules[index] = Rule(
                  name: name,
                  type: rule.type,
                  points: points,
                  createdAt: rule.createdAt,
                );

                // Update the cache for the current mode
                String currentModeKey = _selectedRuleMode.apiMode;
                _cachedRules[currentModeKey] = List<Rule>.from(_rules);
              });

              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);

      // Update the cache for the current mode
      String currentModeKey = _selectedRuleMode.apiMode;
      _cachedRules[currentModeKey] = List<Rule>.from(_rules);
    });
  }

  void _submitForm() {
    // Dismiss keyboard when submitting form
    FocusManager.instance.primaryFocus?.unfocus();

    if (_formKey.currentState!.validate()) {
      if (_rules.isEmpty) {
        showSnackBar(
          'Aggiungi almeno una regola prima di creare la lega.',
          color: ColorPalette.warning,
        );
        return;
      }

      setState(() {
        _isCreating = true;
      });

      // Show loading dialog while processing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: true,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.secondaryBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(context.primaryColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Creazione della lega in corso...',
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      {
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

  void _handleRuleModeChanged(GameMode mode) {
    // Store current rules in cache before switching
    String currentModeKey = _selectedRuleMode.apiMode;

    // Save current rules to cache
    if (_rules.isNotEmpty) {
      _cachedRules[currentModeKey] = List<Rule>.from(_rules);
    }

    // Set new mode and clear rules
    setState(() {
      _selectedRuleMode = mode;
      _rules = [];
      _rulesLoaded = false;
    });

    // Load rules for the new mode
    if (mode == GameMode.custom) {
      // For custom mode, either load cached custom rules or set empty
      if (_cachedRules['custom']!.isNotEmpty) {
        setState(() {
          _rules = List<Rule>.from(_cachedRules['custom']!);
          _rulesLoaded = true;
        });
      } else {
        setState(() {
          _rulesLoaded = true;
        });
      }
    } else {
      // For predefined modes, load from local constants
      _loadPredefinedRules(mode.apiMode);
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
          showSnackBar(
            "Compila tutti i campi obbligatori!",
            color: ColorPalette.warning,
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
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueSuccess) {
          // Clear cached rules after successful league creation
          _cachedRules['male'] = [];
          _cachedRules['female'] = [];
          _cachedRules['mixed'] = [];
          _cachedRules['custom'] = [];

          //Go to the league created page
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
          showSnackBar(state.message);
        }
        // No longer need to handle RulesLoaded state since we're using local rules
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Crea Lega',
              style: context.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            leading: BackButton(
              onPressed: Navigator.of(context).pop,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: context.secondaryBgColor,
                    colorScheme: context.colorScheme.copyWith(
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
                              "Compila tutti i campi obbligatori!",
                              color: ColorPalette.warning,
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
                        title:
                            Text('Tipo', style: context.textTheme.labelLarge),
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
                                  onPressed: () {
                                    details.onStepCancel?.call();
                                  },
                                  child: const Text('Indietro'),
                                ),
                              ),
                            if (_currentStep > 0)
                              const SizedBox(width: ThemeSizes.sm),
                            Expanded(
                              flex: 4,
                              child: ElevatedButton(
                                onPressed: _isCreating
                                    ? null
                                    : () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        details.onStepContinue?.call();
                                      },
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
                            onPressed: _isCreating
                                ? null
                                : () {
                                    _submitForm();
                                  },
                            style: ElevatedButton.styleFrom(
                              fixedSize: null,
                              padding: const EdgeInsets.symmetric(
                                vertical: ThemeSizes.md,
                                horizontal: ThemeSizes.sm,
                              ),
                              textStyle: context.textTheme.labelLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(
                              _isCreating
                                  ? 'Creazione in corso...'
                                  : 'Crea Lega',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Widget custom per gestire lo stato del tipo di regola
class _AddRuleDialog extends StatefulWidget {
  final void Function(Rule) onAdd;
  const _AddRuleDialog({required this.onAdd});

  @override
  State<_AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<_AddRuleDialog> {
  final nameController = TextEditingController();
  final pointsController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RuleType ruleType = RuleType.bonus;

  @override
  Widget build(BuildContext context) {
    return FormDialog.ruleForm(
      title: 'Aggiungi Regola',
      isBonus: ruleType == RuleType.bonus,
      formKey: formKey,
      primaryActionText: 'Aggiungi',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo di Regola', style: context.textTheme.titleMedium),
          const SizedBox(height: ThemeSizes.sm),
          TypeSelector(
            selectedType: ruleType,
            onTypeChanged: (type) => setState(
              () => ruleType = type,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome Regola',
              hintText: 'Inserisci il nome della regola',
              prefixIcon: Icon(Icons.text_fields),
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          TextField(
            controller: pointsController,
            decoration: InputDecoration(
              labelText: 'Punti',
              hintText: 'Valore dei punti',
              prefixIcon: Icon(
                Icons.star,
                color: ruleType == RuleType.bonus
                    ? ColorPalette.success
                    : ColorPalette.error,
              ),
              suffixText: 'pt',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      onPrimaryAction: () {
        final name = nameController.text.trim();
        final String pointsText = pointsController.text.trim();
        if (name.isNotEmpty && pointsText.isNotEmpty) {
          final double points = double.tryParse(pointsText) ?? 0;
          widget.onAdd(Rule(
            name: name,
            type: ruleType,
            points: ruleType == RuleType.bonus ? points.abs() : -points.abs(),
            createdAt: DateTime.now(),
          ));
          Navigator.pop(context);
        }
      },
    );
  }
}
