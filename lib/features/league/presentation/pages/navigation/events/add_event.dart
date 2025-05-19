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
  bool _isFromRule = true;
  Rule? _selectedRule;
  final _formKey = GlobalKey<FormState>();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isSubmitting ? null : _submitEvent,
              tooltip: 'Salva Evento',
            )
          ],
        ),
        body: !isAdmin
            ? Center(
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
              )
            : (league == null
                ? Center(
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
                  )
                : _buildEventForm(context, league)),
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

  Widget _buildEventForm(BuildContext context, League league) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source selection card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fonte dell\'evento',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Rules selection if from rule
            if (_isFromRule) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Column(
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
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(ThemeSizes.sm),
                          itemCount: league.rules.length,
                          itemBuilder: (context, index) {
                            final rule = league.rules[index];
                            final isSelected =
                                (_selectedRule?.name.trim().toLowerCase() ==
                                    rule.name.trim().toLowerCase());

                            return Card(
                              color: isSelected
                                  ? context.primaryColor.withValues(alpha: 0.1)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeSizes.borderRadiusSm),
                                side: isSelected
                                    ? BorderSide(
                                        color: context.primaryColor, width: 2)
                                    : BorderSide.none,
                              ),
                              elevation: isSelected ? 2 : 0,
                              margin:
                                  const EdgeInsets.only(bottom: ThemeSizes.sm),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
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
                    ],
                  ),
                ),
              ),
              if (_selectedRule != null) ...[
                const SizedBox(height: ThemeSizes.md),
                Card(
                  color: _selectedRule!.type == RuleType.bonus
                      ? ColorPalette.success.withValues(alpha: 0.1)
                      : ColorPalette.error.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
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
                ),
              ],
              const SizedBox(height: ThemeSizes.lg),
            ],

            // Event details card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: context.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: ThemeSizes.sm),
                        Text(
                          'Dettagli Evento',
                          style: context.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
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
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                        prefixIcon: const Icon(Icons.score),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
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
                    // Dropdown to select participant
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Assegna a',
                        hintText: 'Seleziona un partecipante',
                        filled: true,
                        fillColor: context.secondaryBgColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
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
                    const SizedBox(height: ThemeSizes.md),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descrizione (opzionale)',
                        hintText: 'Inserisci una descrizione',
                        filled: true,
                        fillColor: context.secondaryBgColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: ThemeSizes.xl),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitEvent,
                icon: _isSubmitting
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.add_circle_outline),
                label:
                    Text(_isSubmitting ? 'Salvataggio...' : 'Aggiungi Evento'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  ),
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom widget for source selection buttons
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
