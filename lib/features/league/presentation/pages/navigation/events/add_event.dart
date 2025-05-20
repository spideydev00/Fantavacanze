import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter/material.dart';
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

  // State variables
  bool _isFromRule = true;
  Rule? _selectedRule;
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedParticipantId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEventSource(bool value) {
    setState(() {
      _isFromRule = value;
      if (!_isFromRule) {
        _selectedRule = null;
      }
    });
  }

  void _selectRule(Rule rule) {
    setState(() {
      _selectedRule = rule;
      _nameController.text = rule.name;
      _pointsController.text = rule.points.toString();
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
      showSnackBar(context, 'Nessuna lega selezionata',
          color: ColorPalette.error);
      return;
    }

    // Check if user is admin before allowing event creation
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    if (!isAdmin) {
      showSnackBar(context, 'Solo gli amministratori possono aggiungere eventi',
          color: ColorPalette.error);
      return;
    }

    final currentUserState = context.read<AppUserCubit>().state;
    if (currentUserState is! AppUserIsLoggedIn) {
      showSnackBar(context, 'Utente non autenticato',
          color: ColorPalette.error);
      return;
    }

    // Start submitting
    setState(() {
      _isSubmitting = true;
    });

    // The ID of the admin creating this event
    final creatorId = currentUserState.user.id;

    // The ID of the participant receiving the points
    final targetUserId = _selectedParticipantId;
    if (targetUserId == null) {
      setState(() {
        _isSubmitting = false;
      });
      showSnackBar(
        context,
        'Seleziona un partecipante a cui assegnare l\'evento',
        color: ColorPalette.error,
      );
      return;
    }

    final name = _nameController.text.trim();
    final points = int.parse(_pointsController.text.trim());
    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : null;

    // Determine event type based on points sign or selected rule
    final eventType =
        _selectedRule?.type ?? (points >= 0 ? RuleType.bonus : RuleType.malus);

    context.read<LeagueBloc>().add(
          AddEventEvent(
            league: league,
            name: name,
            points: points,
            creatorId: creatorId,
            targetUser: targetUserId,
            type: eventType,
            description: description,
          ),
        );
  }

  bool _validateStep(int step) {
    if (step == 0) {
      // No validation for source selection
      return true;
    } else if (step == 1) {
      // Validate event details
      if (_nameController.text.trim().isEmpty) {
        showSnackBar(context, 'Inserisci un nome per l\'evento',
            color: ColorPalette.warning);
        return false;
      }

      if (_pointsController.text.trim().isEmpty) {
        showSnackBar(context, 'Inserisci i punti per l\'evento',
            color: ColorPalette.warning);
        return false;
      }

      try {
        int.parse(_pointsController.text.trim());
      } catch (e) {
        showSnackBar(context, 'Inserisci un valore numerico valido',
            color: ColorPalette.warning);
        return false;
      }

      return true;
    } else if (step == 2) {
      // Validate participant selection
      if (_selectedParticipantId == null) {
        showSnackBar(context, 'Seleziona un partecipante',
            color: ColorPalette.warning);
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
            showSnackBar(context, 'Evento aggiunto con successo!',
                color: ColorPalette.success);
            Navigator.of(context).pop();
          } else if (state is LeagueError) {
            showSnackBar(context, state.message, color: ColorPalette.error);
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
            ? _buildUnauthorizedView(context)
            : (league == null
                ? _buildNoLeagueView(context)
                : _buildEventCreationStepper(context, league)),
        bottomNavigationBar: _isSubmitting
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                color: context.primaryColor.withValues(alpha: 0.1),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(width: ThemeSizes.md),
                      Text(
                        'Salvataggio evento in corso...',
                        style: TextStyle(color: context.primaryColor),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 80,
            color: context.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Accesso Non Autorizzato',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'Solo gli amministratori possono aggiungere eventi',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoLeagueView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 80,
            color: ColorPalette.warning.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Nessuna Lega Selezionata',
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCreationStepper(BuildContext context, League league) {
    return Form(
      key: _formKey,
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
                      'Origine',
                      style: context.textTheme.labelLarge,
                    ),
                    content: _buildSourceSelectionStep(context),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : (_currentStep == 0
                            ? StepState.editing
                            : StepState.indexed),
                  ),
                  Step(
                    title: Text(
                      'Dettagli',
                      style: context.textTheme.labelLarge,
                    ),
                    content: _buildEventDetailsStep(context),
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
                    content: _buildAssignEventStep(context, league),
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
                child: const Text('Indietro'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: ThemeSizes.sm),
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                fixedSize: null,
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeSizes.md,
                  horizontal: ThemeSizes.sm,
                ),
              ),
              child: Text(
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
  Widget _buildSourceSelectionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona l\'origine dell\'evento',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildSourceButton(
                context: context,
                isSelected: _isFromRule,
                label: 'Da Regola',
                icon: Icons.rule_folder,
                onTap: () => _toggleEventSource(true),
              ),
            ),
            const SizedBox(width: ThemeSizes.md),
            Expanded(
              child: _buildSourceButton(
                context: context,
                isSelected: !_isFromRule,
                label: 'Personalizzato',
                icon: Icons.create,
                onTap: () => _toggleEventSource(false),
              ),
            ),
          ],
        ),
        if (_isFromRule) ...[
          const SizedBox(height: ThemeSizes.lg),
          _buildRuleSelectionSection(context),
        ],
      ],
    );
  }

  Widget _buildRuleSelectionSection(BuildContext context) {
    final league = _getCurrentLeague();
    if (league == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Container(
          height: Constants.getHeight(context) * 0.22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            border: Border.all(color: context.borderColor),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(ThemeSizes.sm),
            itemCount: league.rules.length,
            itemBuilder: (context, index) {
              final rule = league.rules[index];
              final isSelected = (_selectedRule?.name.trim().toLowerCase() ==
                  rule.name.trim().toLowerCase());

              return Card(
                color: isSelected
                    ? context.primaryColor.withValues(alpha: 0.1)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusSm),
                  side: isSelected
                      ? BorderSide(color: context.primaryColor, width: 2)
                      : BorderSide.none,
                ),
                elevation: isSelected ? 2 : 0,
                margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
                child: ListTile(
                  leading: Icon(
                    rule.type == RuleType.bonus
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                    color: rule.type == RuleType.bonus
                        ? ColorPalette.success
                        : ColorPalette.error,
                  ),
                  title: Text(
                    rule.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${rule.type == RuleType.bonus ? '+' : '-'}${rule.points} punti',
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: ColorPalette.success)
                      : null,
                  onTap: () => _selectRule(rule),
                ),
              );
            },
          ),
        ),
        if (_selectedRule != null) ...[
          const SizedBox(height: ThemeSizes.md),
          _buildSelectedRuleCard(context),
        ],
      ],
    );
  }

  Widget _buildSelectedRuleCard(BuildContext context) {
    if (_selectedRule == null) return const SizedBox.shrink();

    return Card(
      color: _selectedRule!.type == RuleType.bonus
          ? ColorPalette.success.withValues(alpha: 0.1)
          : ColorPalette.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Row(
          children: [
            Icon(
              _selectedRule!.type == RuleType.bonus
                  ? Icons.check_circle_outline
                  : Icons.highlight_off,
              color: _selectedRule!.type == RuleType.bonus
                  ? ColorPalette.success
                  : ColorPalette.error,
              size: 36,
            ),
            const SizedBox(width: ThemeSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Regola selezionata',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _selectedRule!.type == RuleType.bonus
                          ? ColorPalette.success
                          : ColorPalette.error,
                    ),
                  ),
                  Text(
                    _selectedRule!.name,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_selectedRule!.type == RuleType.bonus ? '+' : '-'}${_selectedRule!.points} punti',
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Event Details
  Widget _buildEventDetailsStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inserisci i dettagli dell\'evento',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome evento',
            hintText: 'Inserisci il nome dell\'evento',
            filled: true,
            fillColor: context.secondaryBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Inserisci un nome per l\'evento';
            }
            return null;
          },
          readOnly: _isFromRule && _selectedRule != null,
        ),
        const SizedBox(height: ThemeSizes.md),
        TextFormField(
          controller: _pointsController,
          decoration: InputDecoration(
            labelText: 'Punti',
            hintText: 'Inserisci i punti (positivi o negativi)',
            filled: true,
            fillColor: context.secondaryBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            prefixIcon: const Icon(Icons.score),
          ),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Inserisci un valore';
            }
            try {
              int.parse(value);
              return null;
            } catch (e) {
              return 'Inserisci un numero valido';
            }
          },
          readOnly: _isFromRule && _selectedRule != null,
        ),
        const SizedBox(height: ThemeSizes.md),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Descrizione (opzionale)',
            hintText: 'Inserisci una descrizione',
            filled: true,
            fillColor: context.secondaryBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // STEP 3: Assign Event to Participant
  Widget _buildAssignEventStep(BuildContext context, League league) {
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
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Seleziona partecipante',
            hintText: 'Assegna a',
            filled: true,
            fillColor: context.secondaryBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          value: _selectedParticipantId,
          items: league.participants.map((participant) {
            return DropdownMenuItem<String>(
              value: league.isTeamBased
                  ? participant
                      .name // For team-based leagues, use team name as ID
                  : (participant as dynamic)
                      .userId, // For individual, use userId
              child: Text(participant.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedParticipantId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleziona un partecipante';
            }
            return null;
          },
        ),
        const SizedBox(height: ThemeSizes.xl),
        // Event preview card
        if (_nameController.text.isNotEmpty &&
            _pointsController.text.isNotEmpty)
          _buildEventPreviewCard(context),
      ],
    );
  }

  Widget _buildEventPreviewCard(BuildContext context) {
    final int points = int.tryParse(_pointsController.text) ?? 0;
    final bool isBonus = points >= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anteprima Evento',
              style: context.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: isBonus
                    ? ColorPalette.success.withValues(alpha: 0.2)
                    : ColorPalette.error.withValues(alpha: 0.2),
                child: Icon(
                  isBonus ? Icons.add_circle : Icons.remove_circle,
                  color: isBonus ? ColorPalette.success : ColorPalette.error,
                ),
              ),
              title: Text(
                _nameController.text,
                style: context.textTheme.titleMedium,
              ),
              subtitle: Text(
                '${isBonus ? "+" : ""}$points punti',
                style: TextStyle(
                  color: isBonus ? ColorPalette.success : ColorPalette.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                _selectedParticipantId != null
                    ? 'Pronto per l\'assegnazione'
                    : 'Seleziona un partecipante',
                style: TextStyle(
                  color: _selectedParticipantId != null
                      ? ColorPalette.success
                      : ColorPalette.warning,
                  fontSize: ThemeSizes.labelMd,
                ),
              ),
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
                child: Text(
                  'Descrizione: ${_descriptionController.text}',
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.md,
          horizontal: ThemeSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : context.textSecondaryColor,
            ),
            const SizedBox(width: ThemeSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
