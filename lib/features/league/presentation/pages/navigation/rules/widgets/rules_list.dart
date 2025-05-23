import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/widgets/empty_rules_view.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/widgets/rule_item.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
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
  final Function(BuildContext, League, [bool?])? onAddPressed;

  /// Optional callback to delete a rule
  final Function(BuildContext, League, Rule)? onDeleteRule;

  const RulesList({
    super.key,
    required this.rules,
    required this.emptyMessage,
    required this.isBonus,
    required this.isAdmin,
    required this.league,
    this.onAddPressed,
    this.onDeleteRule,
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
          InfoBanner(
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
                    onEdit:
                        isAdmin ? () => _editRule(context, rule, league) : null,
                    onDelete: isAdmin
                        ? () => onDeleteRule != null
                            ? onDeleteRule!(context, league, rule)
                            : _deleteRule(context, rule, league)
                        : null,
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
      builder: (dialogContext) => FormDialog.ruleForm(
        title: isBonus ? 'Aggiungi Bonus' : 'Aggiungi Malus',
        isBonus: isBonus,
        formKey: formKey,
        primaryActionText: 'Salva',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome Regola',
                hintText: 'Inserisci il nome della regola',
                prefixIcon: const Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            TextField(
              controller: pointsController,
              decoration: InputDecoration(
                labelText: 'Punti',
                hintText: isBonus ? 'Punti bonus' : 'Punti malus',
                prefixIcon: Icon(
                  Icons.star,
                  color: isBonus ? ColorPalette.success : ColorPalette.error,
                ),
                suffixText: 'pt',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: ThemeSizes.md),
            // Info message about points
            Text(
              infoMessage,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        onPrimaryAction: () {
          if (formKey.currentState!.validate()) {
            final name = nameController.text.trim();
            final pointsValue = double.parse(pointsController.text.trim());

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
      ),
    );
  }

  void _editRule(BuildContext context, Rule rule, League league) {
    final nameController = TextEditingController(text: rule.name);
    final pointsController =
        TextEditingController(text: rule.points.abs().toString());
    final formKey = GlobalKey<FormState>();
    final ruleType = rule.type;
    final isBonus = rule.type == RuleType.bonus;

    showDialog(
      context: context,
      builder: (context) => FormDialog.ruleForm(
        title: 'Modifica Regola',
        isBonus: isBonus,
        formKey: formKey,
        primaryActionText: 'Salva',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome Regola',
                hintText: 'Inserisci il nome della regola',
                prefixIcon: const Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            TextField(
              controller: pointsController,
              decoration: InputDecoration(
                labelText: 'Punti',
                hintText: isBonus ? 'Punti bonus' : 'Punti malus',
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
          if (formKey.currentState!.validate()) {
            final pointsValue = double.parse(pointsController.text.trim());
            final name = nameController.text.trim();

            // Create a new Rule
            Rule updatedRule = Rule(
              name: name,
              points: pointsValue,
              type: ruleType,
              createdAt: rule.createdAt,
            );

            // Call method to update rule in database
            context.read<LeagueBloc>().add(
                  UpdateRuleEvent(
                    league: league,
                    rule: updatedRule,
                    originalRuleName: rule.name,
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
    );
  }

  void _deleteRule(BuildContext context, Rule rule, League league) {
    // If no external handler is provided, directly dispatch event
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
  }
}
