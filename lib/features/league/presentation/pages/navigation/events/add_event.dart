import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventPage extends StatefulWidget {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna lega selezionata')),
      );
      return;
    }

    // Check if user is admin before allowing event creation
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solo gli amministratori possono aggiungere eventi')),
      );
      return;
    }

    final currentUserState = context.read<AppUserCubit>().state;
    if (currentUserState is! AppUserIsLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utente non autenticato')),
      );
      return;
    }

    // The ID of the admin creating this event
    final creatorId = currentUserState.user.id;

    // The ID of the participant receiving the points
    final targetUserId = _selectedParticipantId;
    if (targetUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Seleziona un partecipante a cui assegnare l\'evento')),
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

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final league = _getCurrentLeague();
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Evento'),
      ),
      body: !isAdmin
          ? const Center(
              child: Text('Solo gli amministratori possono aggiungere eventi'))
          : (league == null
              ? const Center(child: Text('Nessuna lega selezionata'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(ThemeSizes.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fonte dell\'evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: ThemeSizes.md),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _toggleEventSource(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFromRule
                                      ? context.primaryColor
                                      : context.buttonSecondaryColor,
                                  foregroundColor: _isFromRule
                                      ? Colors.white
                                      : context.textPrimaryColor,
                                ),
                                child: const Text('Da Regola'),
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _toggleEventSource(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !_isFromRule
                                      ? context.primaryColor
                                      : context.buttonSecondaryColor,
                                  foregroundColor: !_isFromRule
                                      ? Colors.white
                                      : context.textPrimaryColor,
                                ),
                                child: const Text('Personalizzato'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ThemeSizes.lg),
                        if (_isFromRule) ...[
                          Text(
                            'Seleziona una regola',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: ThemeSizes.md),
                          Container(
                            height: Constants.getHeight(context) * 0.2,
                            decoration: BoxDecoration(
                              border: Border.all(color: context.borderColor),
                              borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusMd),
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(ThemeSizes.sm),
                              itemCount: league.rules.length,
                              itemBuilder: (context, index) {
                                final rule = league.rules[index];
                                final isSelected =
                                    (_selectedRule?.name.trim().toLowerCase() ==
                                        rule.name.trim().toLowerCase());

                                return ListTile(
                                  title: Text(rule.name),
                                  subtitle: Text(
                                    '${rule.type == RuleType.bonus ? '+' : '-'}${rule.points} punti',
                                    style: TextStyle(
                                      color: rule.type == RuleType.bonus
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  tileColor: isSelected
                                      ? context.primaryColor
                                          .withValues(alpha: 0.1)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        ThemeSizes.borderRadiusSm),
                                  ),
                                  onTap: () => _selectRule(rule),
                                );
                              },
                            ),
                          ),
                          if (_selectedRule != null) ...[
                            const SizedBox(height: ThemeSizes.lg),
                            Text(
                              'Regola selezionata: ${_selectedRule!.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Punti: ${_selectedRule!.points}',
                              style: TextStyle(
                                color: _selectedRule!.type == RuleType.bonus
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: ThemeSizes.lg),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome evento',
                            hintText: 'Inserisci il nome dell\'evento',
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
                          decoration: const InputDecoration(
                            labelText: 'Punti',
                            hintText: 'Inserisci i punti (positivi o negativi)',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(signed: true),
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
                          decoration: const InputDecoration(
                            labelText: 'Assegna a',
                            hintText: 'Seleziona un partecipante',
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
                          decoration: const InputDecoration(
                            labelText: 'Descrizione (opzionale)',
                            hintText: 'Inserisci una descrizione',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: ThemeSizes.xl),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitEvent,
                            child: const Text('Aggiungi Evento'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }
}
