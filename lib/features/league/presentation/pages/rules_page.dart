import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists && state.selectedLeague != null) {
          final league = state.selectedLeague!;
          final isAdmin = context.read<AppLeagueCubit>().isAdmin();

          // Separate rules by type
          final bonusRules = league.rules
              .where((rule) => rule.type == RuleType.bonus)
              .toList();

          final malusRules = league.rules
              .where((rule) => rule.type == RuleType.malus)
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Regole'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'BONUS'),
                  Tab(text: 'MALUS'),
                ],
                indicatorColor: context.primaryColor,
                labelColor: context.textPrimaryColor,
              ),
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddRuleDialog(context, league.id),
                  ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Bonus rules tab
                _RulesList(
                  rules: bonusRules,
                  emptyMessage: 'Nessuna regola bonus disponibile',
                  isAdmin: isAdmin,
                  leagueId: league.id,
                ),

                // Malus rules tab
                _RulesList(
                  rules: malusRules,
                  emptyMessage: 'Nessuna regola malus disponibile',
                  isAdmin: isAdmin,
                  leagueId: league.id,
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Nessuna lega selezionata'));
      },
    );
  }

  void _showAddRuleDialog(BuildContext context, String leagueId) {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    RuleType ruleType = RuleType.bonus;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Aggiungi regola',
            style: TextStyle(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Inserisci il nome della regola',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci un nome per la regola';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: ThemeSizes.md),
                TextFormField(
                  controller: pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Punti',
                    hintText: 'Inserisci il valore dei punti',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci un valore';
                    }
                    try {
                      double.parse(value);
                      return null;
                    } catch (e) {
                      return 'Inserisci un numero valido';
                    }
                  },
                ),
                const SizedBox(height: ThemeSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            ruleType = RuleType.bonus;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeSizes.md,
                            horizontal: ThemeSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: ruleType == RuleType.bonus
                                ? Colors.green.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                            border: Border.all(
                              color: ruleType == RuleType.bonus
                                  ? Colors.green
                                  : context.borderColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bonus',
                                style: TextStyle(
                                  color: ruleType == RuleType.bonus
                                      ? Colors.green
                                      : null,
                                  fontWeight: ruleType == RuleType.bonus
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            ruleType = RuleType.malus;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeSizes.md,
                            horizontal: ThemeSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: ruleType == RuleType.malus
                                ? Colors.red.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                            border: Border.all(
                              color: ruleType == RuleType.malus
                                  ? Colors.red
                                  : context.borderColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Malus',
                                style: TextStyle(
                                  color: ruleType == RuleType.malus
                                      ? Colors.red
                                      : null,
                                  fontWeight: ruleType == RuleType.malus
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final pointsValue =
                      double.parse(pointsController.text.trim());

                  // Convert points based on rule type (malus should be negative)
                  final points = ruleType == RuleType.bonus
                      ? pointsValue.abs()
                      : -pointsValue.abs();

                  // Here you would add the rule to the league
                  // For now, we'll just close the dialog
                  Navigator.pop(context);

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Regola "$name" aggiunta con successo')),
                  );
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesList extends StatelessWidget {
  final List<Rule> rules;
  final String emptyMessage;
  final bool isAdmin;
  final String leagueId;

  const _RulesList({
    required this.rules,
    required this.emptyMessage,
    required this.isAdmin,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rule,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondaryColor,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: ThemeSizes.lg),
              ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(context, leagueId),
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi Regola'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeSizes.md),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        final isBonus = rule.type == RuleType.bonus;

        return Card(
          margin: const EdgeInsets.only(bottom: ThemeSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBonus
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
              ),
              child: Icon(
                isBonus ? Icons.add_circle : Icons.remove_circle,
                color: isBonus ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              rule.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              '${isBonus ? '+' : ''}${rule.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isBonus ? Colors.green : Colors.red,
              ),
            ),
            onTap: isAdmin
                ? () => _showRuleOptions(context, rule, leagueId)
                : null,
          ),
        );
      },
    );
  }

  void _showAddRuleDialog(BuildContext context, String leagueId) {
    // This delegates to the parent's method
    if (context.findAncestorStateOfType<_RulesPageState>() != null) {
      context
          .findAncestorStateOfType<_RulesPageState>()!
          ._showAddRuleDialog(context, leagueId);
    }
  }

  void _showRuleOptions(BuildContext context, Rule rule, String leagueId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.lg,
          horizontal: ThemeSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica regola'),
              onTap: () {
                Navigator.pop(context);
                // Show edit dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: const Text('Elimina regola'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteRule(context, rule, leagueId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteRule(BuildContext context, Rule rule, String leagueId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content:
            Text('Sei sicuro di voler eliminare la regola "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete rule logic would go here
              // For now, just show a confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Regola "${rule.name}" eliminata')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
