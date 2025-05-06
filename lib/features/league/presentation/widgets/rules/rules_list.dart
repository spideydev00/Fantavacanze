import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/empty_rules_view.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_dialog_container.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_dialog_header.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_form_fields.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_action_buttons.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_info_banner.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/rule_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A component to display a list of rules
///
/// This component shows either a list of rules or an empty state
/// with appropriate styling and actions.
class RulesList extends StatelessWidget {
  /// The list of rules to display
  final List<Rule> rules;

  /// Message to display when no rules are available
  final String emptyMessage;

  /// Whether this is for bonus rules (affects colors and icons)
  final bool isBonus;

  /// Whether the user is an admin (affects available actions)
  final bool isAdmin;

  /// The league these rules belong to
  final League league;

  /// Optional callback to add a new rule
  final Function(BuildContext, League)? onAddPressed;

  const RulesList({
    super.key,
    required this.rules,
    required this.emptyMessage,
    required this.isBonus,
    required this.isAdmin,
    required this.league,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate color based on rule type
    final color = isBonus ? ColorPalette.success : ColorPalette.error;

    // Show empty state if no rules
    if (rules.isEmpty) {
      return EmptyRulesView(
        message: emptyMessage,
        color: color,
        isBonus: isBonus,
        isAdmin: isAdmin,
        league: league,
        onAddPressed: onAddPressed ?? showAddRuleDialog,
      );
    }

    // Information message based on rule type
    final infoMessage = isBonus
        ? 'Queste regole assegnano punti bonus ai partecipanti'
        : 'Queste regole sottraggono punti ai partecipanti';

    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        children: [
          // Info banner for rule type
          RuleInfoBanner(
            message: infoMessage,
            color: color,
          ),

          // Rule list
          Expanded(
            child: ListView.builder(
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
                  child: RuleItem(
                    rule: rule,
                    onEdit: isAdmin
                        ? () => _editRule(context, rule, league)
                        : () {},
                    onDelete: isAdmin
                        ? () => _confirmDeleteRule(context, rule, league)
                        : () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddRuleDialog(BuildContext context, League league) {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ruleType = isBonus ? RuleType.bonus : RuleType.malus;

    // Information message based on rule type
    final infoMessage = isBonus
        ? 'I punti bonus verranno aggiunti al punteggio del partecipante'
        : 'I punti malus verranno sottratti dal punteggio del partecipante';

    showDialog(
      context: context,
      builder: (dialogContext) => RuleDialogContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            RuleDialogHeader(
              title: isBonus ? 'Aggiungi Bonus' : 'Aggiungi Malus',
              ruleType: ruleType,
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Form fields
            RuleFormFields(
              formKey: formKey,
              nameController: nameController,
              pointsController: pointsController,
              ruleType: ruleType,
              infoMessage: infoMessage,
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Action buttons
            RuleActionButtons(
              primaryText: 'Salva',
              ruleType: ruleType,
              onPrimaryPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final pointsValue =
                      double.parse(pointsController.text.trim());

                  final rule = Rule(
                    name: name,
                    type: ruleType,
                    points: pointsValue,
                    createdAt: DateTime.now(),
                  );

                  // Add the rule to the league via the bloc
                  context.read<LeagueBloc>().add(
                        AddRuleEvent(
                          league: league,
                          rule: rule,
                        ),
                      );

                  Navigator.pop(context);

                  showSnackBar(
                    context,
                    'Regola "$name" aggiunta con successo',
                    color: ColorPalette.success,
                  );
                }
              },
              primaryIcon: Icons.save,
              secondaryIcon: Icons.close,
              reverseOrder: true,
            ),
          ],
        ),
      ),
    );
  }

  void _editRule(BuildContext context, Rule rule, League league) {
    final nameController = TextEditingController(text: rule.name);
    final pointsController =
        TextEditingController(text: rule.points.abs().toString());
    final formKey = GlobalKey<FormState>();
    final ruleType = rule.type;
    // Store the original rule to properly preserve its properties
    final originalRule = rule;

    showDialog(
      context: context,
      builder: (context) => RuleDialogContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            RuleDialogHeader(
              title: 'Modifica Regola',
              ruleType: ruleType,
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Form fields
            RuleFormFields(
              formKey: formKey,
              nameController: nameController,
              pointsController: pointsController,
              ruleType: ruleType,
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Action buttons
            RuleActionButtons(
              primaryText: 'Salva',
              ruleType: ruleType,
              onPrimaryPressed: () {
                if (formKey.currentState!.validate()) {
                  final pointsValue =
                      double.parse(pointsController.text.trim());
                  final name = nameController.text.trim();

                  // Create a new Rule
                  Rule updatedRule = Rule(
                    name: name,
                    points: pointsValue,
                    type: ruleType,
                    createdAt: originalRule.createdAt,
                  );

                  // Call method to update rule in database
                  context.read<LeagueBloc>().add(
                        UpdateRuleEvent(
                          league: league,
                          rule: updatedRule,
                          originalRuleName: originalRule.name,
                        ),
                      );

                  Navigator.pop(context);

                  // Show a snackbar with feedback
                  showSnackBar(
                    context,
                    "Regola aggiornata con successo",
                    color: ColorPalette.success,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteRule(BuildContext context, Rule rule, League league) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Eliminare questa regola?',
        message: 'Sei sicuro di voler eliminare la regola "${rule.name}"?',
        color: ColorPalette.error,
        confirmText: 'Elimina',
        onConfirm: () {
          // Call the delete rule method
          context.read<LeagueBloc>().add(
                DeleteRuleEvent(
                  league: league,
                  ruleName: rule.name,
                ),
              );

          showSnackBar(
            context,
            'Regola "${rule.name}" eliminata',
            color: ColorPalette.success,
          );
        },
      ),
    );
  }
}
