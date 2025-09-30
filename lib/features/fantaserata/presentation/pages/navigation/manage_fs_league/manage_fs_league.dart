import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_rules_bloc/fs_rules_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/manage_fs_league/winner_photo_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageFsLeaguePage extends StatefulWidget {
  final FsLeague league;

  const ManageFsLeaguePage({
    super.key,
    required this.league,
  });

  @override
  State<ManageFsLeaguePage> createState() => _ManageFsLeaguePageState();
}

class _ManageFsLeaguePageState extends State<ManageFsLeaguePage> {
  // Form controllers for custom rule
  final _formKey = GlobalKey<FormState>();
  final _ruleNameController = TextEditingController();
  final _pointsController = TextEditingController();
  String _selectedRuleType = 'bonus';
  bool _isSubmittingRule = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FsBloc, FsState>(
        listener: (context, state) {
          if (state is WinnerPhotoUploaded) {
            showSnackBar(
              "Foto del vincitore caricata con successo",
              color: ColorPalette.success,
            );
          } else if (state is WinnerPhotoDeleted) {
            showSnackBar(
              "Foto del vincitore eliminata con successo",
              color: ColorPalette.success,
            );
          } else if (state is FsFailure) {
            showSnackBar(
              "Errore: ${state.message}",
              color: ColorPalette.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is FsLoading;

          return BlocListener<FsRulesBloc, FsRulesState>(
            listener: (context, state) {
              if (state is FsRulesLoaded) {
                setState(() {
                  _isSubmittingRule = false;
                });
                showSnackBar(
                  "Regola personalizzata aggiunta con successo!",
                  color: ColorPalette.success,
                );
                _clearForm();
              } else if (state is FsRulesFailure) {
                setState(() {
                  _isSubmittingRule = false;
                });
                showSnackBar(
                  "Errore: ${state.message}",
                  color: ColorPalette.error,
                );
              } else if (state is FsRulesLoading && _isSubmittingRule) {
                // Keep loading state for rule submission
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.lg, vertical: ThemeSizes.sm),
              child: ListView(
                children: [
                  WinnerPhotoSection(
                    leagueId: widget.league.id,
                    isLoading: isLoading,
                  ),
                  SizedBox(height: ThemeSizes.lg),
                  GradientSectionDivider(
                    text: "Regole Personalizzate",
                    color: context.primaryColor,
                  ),
                  _buildCustomRuleForm(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomRuleForm() {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.sm),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Questa regola verrà aggiunta a tutti i partecipanti della lega.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),

            // Rule Name Field
            TextFormField(
              controller: _ruleNameController,
              decoration: InputDecoration(
                labelStyle: context.textTheme.bodyMedium,
                labelText: "Nome della Regola",
                hintText: "Es. Scrocca una terea turchese",
                prefixIcon: Icon(
                  Icons.rule,
                  color: context.primaryColor,
                  size: ThemeSizes.iconSm,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il nome della regola';
                }
                if (value.trim().length < 3) {
                  return 'Il nome deve essere di almeno 3 caratteri';
                }
                return null;
              },
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Points Field
            TextFormField(
              controller: _pointsController,
              decoration: InputDecoration(
                labelStyle: context.textTheme.bodyMedium,
                labelText: "Punti",
                hintText: "Es. 5",
                prefixIcon: Icon(
                  Icons.star,
                  color: context.primaryColor,
                  size: ThemeSizes.iconSm,
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci i punti';
                }
                final points = double.tryParse(value);
                if (points == null) {
                  return 'Inserisci un numero valido';
                }
                if (points <= 0 || points > 100) {
                  return 'I punti devono essere tra 1 e 100';
                }
                return null;
              },
            ),

            const SizedBox(height: ThemeSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildRuleTypeOption(
                    type: 'bonus',
                    label: 'Bonus',
                    icon: Icons.add_circle,
                    color: ColorPalette.success,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: _buildRuleTypeOption(
                    type: 'malus',
                    label: 'Malus',
                    icon: Icons.remove_circle,
                    color: ColorPalette.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.xl),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmittingRule ? null : _submitCustomRule,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRuleType == 'bonus'
                    ? ColorPalette.success
                    : ColorPalette.error,
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
              ),
              child: _isSubmittingRule
                  ? Loader(
                      color: _selectedRuleType == 'bonus'
                          ? ColorPalette.success
                          : ColorPalette.error,
                    )
                  : Text(
                      "Aggiungi ${_selectedRuleType == 'bonus' ? 'Bonus' : 'Malus'}",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleTypeOption({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRuleType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedRuleType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : context.secondaryBgColor,
          border: Border.all(
            color: isSelected ? color : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : context.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: ThemeSizes.sm),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? color : context.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitCustomRule() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmittingRule = true;
    });

    final points = double.parse(_pointsController.text);

    context.read<FsRulesBloc>().add(
          InsertRulesForLeagueFromExistingEvent(
            leagueId: widget.league.id,
            name: _ruleNameController.text.trim(),
            points: points,
            typeText: _selectedRuleType,
          ),
        );
  }

  void _clearForm() {
    _ruleNameController.clear();
    _pointsController.clear();
    setState(() {
      _selectedRuleType = 'bonus';
    });
  }
}
