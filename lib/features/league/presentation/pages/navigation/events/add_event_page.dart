import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/participants/participant_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/widgets/app_search_bar.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/widgets/event_preview_card.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/widgets/selected_rule_card.dart';
import 'package:fantavacanze_official/core/widgets/rules/type_selector.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/widgets/rule_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventPage extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const AddEventPage());
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Step 1: Source Selection
  bool _isFromRule = true;
  Rule? _selectedRule;

  // Step 2: Event Details
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  RuleType _selectedType = RuleType.bonus;

  // Step 3: Assignment
  String? _selectedParticipantId; // This can be team name or member userId
  bool _isTeamMember = false; // Flag to indicate if selection is a team member
  String? selectedTeamName; // For displaying team name when member is selected

  // UI State
  bool _isSubmitting = false;
  bool _areButtonsVisible = true;
  bool _isScrolling = false;
  bool _showTeamMembers = false; // Toggle between teams and members view

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_currentStep == 1 && _isFromRule) {
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

  void _toggleEventSource(bool value) {
    setState(() {
      _isFromRule = value;
      if (!_isFromRule) {
        _selectedRule = null;
        // Reset fields when switching to custom
        _nameController.clear();
        _pointsController.clear();
      }
    });
  }

  void _selectRule(Rule rule) {
    setState(() {
      _selectedRule = rule;
      _nameController.text = rule.name;
      _pointsController.text = rule.points.toString().replaceAll('.0', '');
    });
  }

  League? _getCurrentLeague() {
    final state = context.read<AppLeagueCubit>().state;
    if (state is AppLeagueExists) {
      return state.selectedLeague;
    }
    return null;
  }

  void _submitEvent() {
    if (!_formKey.currentState!.validate()) return;

    final league = _getCurrentLeague();
    if (league == null) {
      showSnackBar(
        'Nessuna lega selezionata',
        color: ColorPalette.error,
      );
      return;
    }

    // Check if user is admin before allowing event creation
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    if (!isAdmin) {
      showSnackBar(
        'Solo gli amministratori possono aggiungere eventi',
        color: ColorPalette.error,
      );
      return;
    }

    final currentUserState = context.read<AppUserCubit>().state;
    if (currentUserState is! AppUserIsLoggedIn) {
      showSnackBar(
        'Utente non autenticato',
        color: ColorPalette.error,
      );
      return;
    }

    // Start submitting
    setState(() {
      _isSubmitting = true;
    });

    // The ID of the admin creating this event
    final creatorId = currentUserState.user.id;

    // The ID of the participant receiving the points
    final targetUser = _selectedParticipantId;
    if (targetUser == null) {
      setState(() {
        _isSubmitting = false;
      });
      showSnackBar(
        'Seleziona un partecipante a cui assegnare l\'evento',
        color: ColorPalette.error,
      );
      return;
    }

    final name = _nameController.text.trim();

    // Parse points, normalizing decimal separator
    final double points = double.parse(_pointsController.text
        .trim()
        .replaceAll(',', '.')
        .replaceFirst(RegExp(r'\.0+$'), ''));

    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : null;

    // Determine event type and adjust points based on type
    final RuleType eventType;
    double finalPoints;

    if (_isFromRule) {
      // If from rule, use the rule's type
      eventType = _selectedRule?.type ?? RuleType.bonus;
      finalPoints = points;
    } else {
      // If custom event, use the selected type
      eventType = _selectedType;
      finalPoints = points;
    }

    // Ensure malus events have negative points
    if (eventType == RuleType.malus && finalPoints > 0) {
      finalPoints = -finalPoints;
    }

    context.read<LeagueBloc>().add(
          AddEventEvent(
            league: league,
            name: name,
            points: finalPoints,
            creatorId: creatorId,
            targetUser: targetUser,
            type: eventType,
            description: description,
            isTeamMember: _isTeamMember,
          ),
        );
  }

  bool _validateStep(int step) {
    if (step == 0) {
      // No validation needed for source selection
      return true;
    } else if (step == 1) {
      // Validate event details
      if (_nameController.text.trim().isEmpty) {
        showSnackBar('Inserisci un nome per l\'evento',
            color: ColorPalette.warning);
        return false;
      }

      if (_pointsController.text.trim().isEmpty) {
        showSnackBar('Inserisci i punti per l\'evento',
            color: ColorPalette.warning);
        return false;
      }

      try {
        // Normalize input with comma to period
        final normalizedInput =
            _pointsController.text.trim().replaceAll(',', '.');
        double.parse(normalizedInput);
      } catch (e) {
        showSnackBar('Inserisci un valore numerico valido',
            color: ColorPalette.warning);
        return false;
      }

      return true;
    } else if (step == 2) {
      // Validate participant selection
      if (_selectedParticipantId == null) {
        showSnackBar('Seleziona un partecipante', color: ColorPalette.warning);
        return false;
      }
      return true;
    }
    return true;
  }

  void _onStepTapped(int step) {
    // Only allow navigation to steps that we've already visited or the next step
    if (step <= _currentStep || step == _currentStep + 1) {
      // Validate current step if moving forward
      if (step > _currentStep && !_validateStep(_currentStep)) {
        return;
      }

      setState(() {
        _currentStep = step;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final league = _getCurrentLeague();
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
          });

          if (state is LeagueSuccess && state.operation == 'add_event') {
            showSnackBar('Evento aggiunto con successo!',
                color: ColorPalette.success);
            Navigator.of(context).pop();
          } else if (state is LeagueError) {
            showSnackBar(state.message, color: ColorPalette.error);
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          title: const Text('Nuovo Evento'),
          elevation: 0,
        ),
        body: !isAdmin
            ? _buildUnauthorizedView()
            : (league == null
                ? _buildNoLeagueView()
                : _buildEventCreationStepper(league)),
      ),
    );
  }

  Widget _buildUnauthorizedView() {
    return Center(
      child: InfoContainer(
        icon: Icons.admin_panel_settings,
        title: 'Accesso Non Autorizzato',
        message: 'Solo gli amministratori possono aggiungere eventi',
        color: context.primaryColor.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildNoLeagueView() {
    return Center(
      child: InfoContainer(
        icon: Icons.warning_amber_rounded,
        title: 'Nessuna Lega Selezionata',
        message: 'Seleziona una lega prima di aggiungere un evento',
        color: ColorPalette.warning.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEventCreationStepper(League league) {
    return Form(
      key: _formKey,
      child: Column(
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
                    if (!_validateStep(_currentStep)) {
                      return;
                    }
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _submitEvent();
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
                      'Fonte',
                      style: context.textTheme.labelLarge,
                    ),
                    content: _buildSourceSelectionStep(),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.editing,
                  ),
                  Step(
                    title: Text(
                      'Dettagli',
                      style: context.textTheme.labelLarge,
                    ),
                    content: _buildEventDetailsStep(),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : (_currentStep == 1
                            ? StepState.editing
                            : StepState.indexed),
                  ),
                  Step(
                    title: Text(
                      'Assegna',
                      style: context.textTheme.labelLarge,
                    ),
                    content: _buildAssignEventStep(league),
                    isActive: _currentStep >= 2,
                    state: _currentStep == 2
                        ? StepState.editing
                        : StepState.indexed,
                  ),
                ],
                controlsBuilder: _buildStepperControls,
              ),
            ),
          ),
          if (_isSubmitting)
            SizedBox(
              height: Constants.getHeight(context) * 0.1,
              child: Loader(
                color: ColorPalette.success,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: ThemeSizes.lg),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 3,
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor),
                ),
                child: const Text('Indietro'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: ThemeSizes.sm),
          Expanded(
            flex: 4,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeSizes.md,
                  horizontal: ThemeSizes.sm,
                ),
                elevation: 2,
              ),
              label: Text(
                _isSubmitting
                    ? 'Salvataggio...'
                    : _currentStep < 2
                        ? 'Continua'
                        : 'Crea Evento',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: Source Selection
  Widget _buildSourceSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona l\'origine dell\'evento',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.xl),
        Row(
          children: [
            Expanded(
              child: GradientOptionButton(
                isSelected: _isFromRule,
                label: 'Da Regola',
                icon: Icons.rule_folder,
                onTap: () => _toggleEventSource(true),
                description: 'Seleziona dalle regole esistenti',
                primaryColor: context.primaryColor,
                secondaryColor: ColorPalette.info,
              ),
            ),
            const SizedBox(width: ThemeSizes.lg),
            Expanded(
              child: GradientOptionButton(
                isSelected: !_isFromRule,
                label: 'Custom',
                icon: Icons.create,
                onTap: () => _toggleEventSource(false),
                description: 'Eventi non presi dalle regole',
                primaryColor: ColorPalette.success,
                secondaryColor: ColorPalette.darkerGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: Event Details
  Widget _buildEventDetailsStep() {
    final league = _getCurrentLeague();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isFromRule && league != null) ...[
          Row(
            children: [
              Icon(
                Icons.rule,
                color: context.primaryColor,
                size: 22,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                'Seleziona una regola',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.md),

          // Search bar for rules
          AppSearchBar(
            controller: _searchController,
            hintText: 'Cerca regola...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),

          // If a rule is selected, show it above the list
          if (_selectedRule != null)
            SelectedRuleCard(
              rule: _selectedRule!,
              onClear: () {
                setState(() {
                  _selectedRule = null;
                  _nameController.clear();
                  _pointsController.clear();
                });
              },
            ),

          const SizedBox(height: ThemeSizes.sm),

          // Rules container - takes most of the available space
          Container(
            height: _selectedRule != null
                ? Constants.getHeight(context) * 0.33
                : Constants.getHeight(context) * 0.47,
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: league.rules.isEmpty
                ? Center(
                    child: InfoContainer(
                      icon: Icons.rule_folder_outlined,
                      title: 'Nessuna regola disponibile',
                      message: 'Questa lega non ha regole configurate',
                      color: ColorPalette.warning,
                    ),
                  )
                : Builder(
                    builder: (context) {
                      // Create a filtered list of rules based on search query
                      final filteredRules = _searchQuery.isEmpty
                          ? league.rules
                          : league.rules
                              .where((rule) => rule.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();

                      if (filteredRules.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: context.textSecondaryColor
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: ThemeSizes.sm),
                              Text(
                                'Nessuna regola trovata',
                                style: TextStyle(
                                  color: context.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: ThemeSizes.xs),
                              Text(
                                'Prova con un\'altra ricerca',
                                style: TextStyle(
                                  color: context.textSecondaryColor
                                      .withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(ThemeSizes.sm),
                        itemCount: filteredRules.length,
                        itemBuilder: (context, index) {
                          final rule = filteredRules[index];
                          final isSelected = _selectedRule?.name == rule.name;
                          return RuleItem(
                            rule: rule,
                            isSelected: isSelected,
                            onTap: () => _selectRule(rule),
                          );
                        },
                      );
                    },
                  ),
          ),
        ] else ...[
          Text(
            'Inserisci i dettagli dell\'evento',
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),

          // Add type selector for custom events
          TypeSelector(
            selectedType: _selectedType,
            onTypeChanged: (type) {
              setState(() {
                _selectedType = type;
              });
            },
          ),
          const SizedBox(height: ThemeSizes.md),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome evento',
              hintText: 'Inserisci il nome dell\'evento',
              filled: true,
              fillColor: context.secondaryBgColor,
              prefixIcon: Icon(
                Icons.title,
                color: context.secondaryColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un nome per l\'evento';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeSizes.md),
          TextFormField(
            controller: _pointsController,
            decoration: InputDecoration(
              labelText: 'Punti',
              hintText: _selectedType == RuleType.bonus
                  ? 'Punti Bonus (1, 1.5, 2, etc..)'
                  : 'Punti Malus (valore positivo)',
              filled: true,
              fillColor: context.secondaryBgColor,
              prefixIcon: Icon(
                _selectedType == RuleType.bonus
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: _selectedType == RuleType.bonus
                    ? ColorPalette.success
                    : ColorPalette.error,
              ),
            ),
            inputFormatters: [
              // Allow digits, comma, period
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
            ],
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un valore';
              }
              try {
                // Normalize for validation
                final normalizedInput = value.trim().replaceAll(',', '.');
                double.parse(normalizedInput);
                return null;
              } catch (e) {
                return 'Inserisci un numero valido';
              }
            },
            onChanged: (value) {
              // Auto-normalize display
              if (value.contains(',')) {
                final normalized = value.replaceAll(',', '.');

                // If ends with .0, truncate
                if (normalized.endsWith('.0')) {
                  _pointsController.text =
                      normalized.substring(0, normalized.length - 2);
                  _pointsController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _pointsController.text.length),
                  );
                }
              }
            },
          ),
          const SizedBox(height: ThemeSizes.md),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Descrizione (opzionale)',
              hintText: 'Inserisci una descrizione',
              filled: true,
              fillColor: context.secondaryBgColor,
              prefixIcon: Icon(
                Icons.description,
                color: context.secondaryColor,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  // STEP 3: Assign Event to Participant
  Widget _buildAssignEventStep(League league) {
    // Calculate points and determine if it's a bonus or malus
    double points;
    try {
      // Parse the input and normalize comma to period
      final normalizedInput =
          _pointsController.text.trim().replaceAll(',', '.');
      points = double.tryParse(normalizedInput) ?? 0.0;

      // Adjust points sign based on event type
      if (!_isFromRule) {
        // For custom events, apply sign based on selected type
        if (_selectedType == RuleType.malus && points > 0) {
          points = -points; // Make it negative for malus
        }
      } else if (_selectedRule != null) {
        // For rule-based events, use the rule's points (sign already correct)
        points = _selectedRule!.points;

        // Ensure malus rules have negative points
        if (_selectedRule!.type == RuleType.malus && points > 0) {
          points = -points; // Force negative for malus rules
        }
      }
    } catch (e) {
      points = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assegna l\'evento a un partecipante',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),

        // Event preview card
        if (_nameController.text.isNotEmpty &&
            _pointsController.text.isNotEmpty)
          EventPreviewCard(
            name: _nameController.text,
            points: points, // Now correctly signed
            description: _descriptionController.text,
            hasSelectedParticipant: _selectedParticipantId != null,
          ),

        const SizedBox(height: ThemeSizes.lg),

        // Add search field for participants
        AppSearchBar(
          controller: _searchController,
          hintText: 'Cerca partecipante...',
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),

        const SizedBox(height: ThemeSizes.md),

        // Only show toggle for team-based leagues
        if (league.isTeamBased) _buildParticipantToggle(),

        const SizedBox(height: ThemeSizes.md),

        // Divider with appropriate text
        CustomDivider(
            text: league.isTeamBased
                ? (_showTeamMembers ? 'Seleziona Membro' : 'Seleziona Squadra')
                : 'Seleziona Partecipante'),

        const SizedBox(height: ThemeSizes.md),

        // Show either teams or individual participants
        if (league.isTeamBased)
          (_showTeamMembers
              ? _buildTeamMembersGrid(league)
              : _buildTeamsGrid(league))
        else
          _buildIndividualParticipantsGrid(league),
      ],
    );
  }

  // Toggle between teams and members view
  Widget _buildParticipantToggle() {
    return Row(
      children: [
        Expanded(
          child: GradientOptionButton(
            isSelected: !_showTeamMembers,
            label: 'Squadre',
            icon: Icons.groups,
            onTap: () => setState(() {
              _showTeamMembers = false;
              _selectedParticipantId = null;
              _isTeamMember = false;
              selectedTeamName = null;
            }),
            description: 'Assegna alla squadra',
            primaryColor: context.primaryColor,
            secondaryColor: ColorPalette.info,
          ),
        ),
        const SizedBox(width: ThemeSizes.md),
        Expanded(
          child: GradientOptionButton(
            isSelected: _showTeamMembers,
            label: 'Membri',
            icon: Icons.person,
            onTap: () => setState(() {
              _showTeamMembers = true;
              _selectedParticipantId = null;
              _isTeamMember = false;
              selectedTeamName = null;
            }),
            description: 'Assegna a un membro',
            primaryColor: ColorPalette.info,
            secondaryColor: context.primaryColor,
          ),
        ),
      ],
    );
  }

  // Grid of teams for selection
  Widget _buildTeamsGrid(League league) {
    final filteredTeams = league.participants.where((participant) {
      if (_searchQuery.isEmpty) return true;
      return participant.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredTeams.isEmpty) {
      return Center(
        child: InfoContainer(
          icon: Icons.search_off,
          title: 'Nessun risultato',
          message: 'Nessuna squadra trovata con questo nome',
          color: ColorPalette.warning.withValues(alpha: 0.5),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTeams.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: ThemeSizes.sm),
      itemBuilder: (context, index) {
        final team = filteredTeams[index];
        final isSelected =
            _selectedParticipantId == team.name && !_isTeamMember;

        return ParticipantCard(
          name: team.name,
          points: team.points,
          isSelected: isSelected,
          showPoints: true,
          isFullWidth: true,
          subtitle: '${(team as TeamParticipant).members.length} membri',
          avatarUrl: team.teamLogoUrl,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedParticipantId = null;
                _isTeamMember = false;
                selectedTeamName = null;
              } else {
                _selectedParticipantId = team.name;
                _isTeamMember = false;
                selectedTeamName = null;
              }
            });
          },
        );
      },
    );
  }

  // Grid of team members for selection
  Widget _buildTeamMembersGrid(League league) {
    // Flatten all team members into a single list
    final allMembers = <Map<String, dynamic>>[];

    for (final participant in league.participants) {
      if (participant is TeamParticipant) {
        for (final member in participant.members) {
          if (_searchQuery.isEmpty ||
              member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              participant.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) {
            allMembers.add({
              'userId': member.userId,
              'name': member.name,
              'points': member.points,
              'teamName': participant.name,
              'teamLogoUrl': participant.teamLogoUrl,
              'isCaptain': participant.captainId == member.userId,
            });
          }
        }
      }
    }

    if (allMembers.isEmpty) {
      return Center(
        child: InfoContainer(
          icon: Icons.search_off,
          title: 'Nessun risultato',
          message: 'Nessun membro trovato con questo nome',
          color: ColorPalette.warning.withValues(alpha: 0.5),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allMembers.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: ThemeSizes.sm),
      itemBuilder: (context, index) {
        final member = allMembers[index];
        final isSelected =
            _selectedParticipantId == member['userId'] && _isTeamMember;

        return ParticipantCard(
          name: member['name'],
          points: member['points'],
          isSelected: isSelected,
          showPoints: true,
          isFullWidth: true,
          subtitle: '${member['teamName']}',
          avatarUrl: member['teamLogoUrl'],
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedParticipantId = null;
                _isTeamMember = false;
                selectedTeamName = null;
              } else {
                _selectedParticipantId = member['userId'];
                _isTeamMember = true;
                selectedTeamName = member['teamName'];
              }
            });
          },
        );
      },
    );
  }

  // Grid of individual participants for selection
  Widget _buildIndividualParticipantsGrid(League league) {
    final filteredParticipants = league.participants.where((participant) {
      if (_searchQuery.isEmpty) return true;
      return participant.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredParticipants.isEmpty) {
      return Center(
        child: InfoContainer(
          icon: Icons.search_off,
          title: 'Nessun risultato',
          message: 'Nessun partecipante trovato con questo nome',
          color: ColorPalette.warning.withValues(alpha: 0.5),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredParticipants.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: ThemeSizes.sm),
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];
        final participantId = (participant as IndividualParticipant).userId;
        final isSelected = _selectedParticipantId == participantId;

        return ParticipantCard(
          name: participant.name,
          points: participant.points,
          isSelected: isSelected,
          isFullWidth: true,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedParticipantId = null;
              } else {
                _selectedParticipantId = participantId;
              }
            });
          },
        );
      },
    );
  }
}
