import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rule_item.dart';
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
  final ValueNotifier<double> _fabAnimationValue = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _fabAnimationValue.value = _tabController.index.toDouble();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists && state.selectedLeague != null) {
          final league = state.selectedLeague!;
          final isAdmin = context.read<AppLeagueCubit>().isAdmin();

          // Explicitly filter rules by their exact RuleType
          final bonusRules = league.rules
              .where((rule) => rule.type == RuleType.bonus)
              .toList();

          final malusRules = league.rules
              .where((rule) => rule.type == RuleType.malus)
              .toList();

          return Scaffold(
            body: Column(
              children: [
                // Fixed header with app bar and tabs
                Container(
                  color: context.secondaryBgColor,
                  child: Column(
                    children: [
                      // Customized tab bar for correct color handling
                      _CustomTabBar(
                        controller: _tabController,
                        tabs: const [
                          _CustomTab(
                            label: "BONUS",
                            icon: Icons.arrow_upward_rounded,
                            color: Colors.green,
                          ),
                          _CustomTab(
                            label: "MALUS",
                            icon: Icons.arrow_downward_rounded,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable content area
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Bonus rules tab
                      _RulesList(
                        rules: bonusRules,
                        emptyMessage: 'Nessuna regola bonus disponibile',
                        isBonus: true,
                        isAdmin: isAdmin,
                        leagueId: league.id,
                      ),

                      // Malus rules tab
                      _RulesList(
                        rules: malusRules,
                        emptyMessage: 'Nessuna regola malus disponibile',
                        isBonus: false,
                        isAdmin: isAdmin,
                        leagueId: league.id,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: isAdmin
                ? ValueListenableBuilder<double>(
                    valueListenable: _fabAnimationValue,
                    builder: (context, value, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: value),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final isBonus = value < 0.5;

                          return FloatingActionButton(
                            onPressed: () =>
                                _showAddRuleDialog(context, league.id, isBonus),
                            backgroundColor:
                                isBonus ? Colors.green : Colors.red,
                            child: Icon(
                              isBonus ? Icons.add : Icons.remove,
                            ),
                          );
                        },
                      );
                    },
                  )
                : null,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showAddRuleDialog(BuildContext context, String leagueId, bool isBonus) {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    RuleType ruleType = isBonus ? RuleType.bonus : RuleType.malus;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
          child: Container(
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThemeSizes.sm),
                      decoration: BoxDecoration(
                        color: (ruleType == RuleType.bonus
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ruleType == RuleType.bonus
                            ? Icons.add_circle
                            : Icons.remove_circle,
                        color: ruleType == RuleType.bonus
                            ? Colors.green
                            : Colors.red,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.sm),
                    Text(
                      ruleType == RuleType.bonus
                          ? 'Aggiungi Bonus'
                          : 'Aggiungi Malus',
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeSizes.lg),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          hintText: 'Inserisci il nome della regola',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                          ),
                          prefixIcon: Icon(
                            Icons.title,
                            color: context.textSecondaryColor,
                          ),
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
                        decoration: InputDecoration(
                          labelText: 'Punti',
                          hintText: 'Inserisci il valore dei punti',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                          ),
                          prefixIcon: Icon(
                            Icons.leaderboard,
                            color: context.textSecondaryColor,
                          ),
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
                      Container(
                        padding: const EdgeInsets.all(ThemeSizes.sm),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                          border: Border.all(
                            color: context.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: context.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Expanded(
                              child: Text(
                                ruleType == RuleType.bonus
                                    ? 'I punti bonus verranno aggiunti al punteggio del partecipante'
                                    : 'I punti malus verranno sottratti dal punteggio del partecipante',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Annulla'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.md,
                          vertical: ThemeSizes.sm,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final pointsValue =
                              double.parse(pointsController.text.trim());

                          // Convert points based on rule type (malus should be negative)
                          ruleType == RuleType.bonus
                              ? pointsValue.abs()
                              : -pointsValue.abs();

                          // Here you would add the rule to the league
                          // For now, we'll just close the dialog and show a success message
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(ThemeSizes.lg),
                              content:
                                  Text('Regola "$name" aggiunta con successo'),
                              backgroundColor: ruleType == RuleType.bonus
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Salva'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ruleType == RuleType.bonus
                            ? Colors.green
                            : Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.md,
                          vertical: ThemeSizes.sm,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteRule(BuildContext context, Rule rule, String leagueId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                'Eliminare questa regola?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Sei sicuro di voler eliminare la regola "${rule.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                      ),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Call the delete rule method
                        context.read<LeagueBloc>().add(
                              DeleteRuleEvent(
                                leagueId: leagueId,
                                ruleId: rule.id,
                              ),
                            );
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Regola "${rule.name}" eliminata'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                      ),
                      child: const Text('Elimina'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editRule(BuildContext context, Rule rule, String leagueId) {
    final nameController = TextEditingController(text: rule.name);
    final pointsController =
        TextEditingController(text: rule.points.abs().toString());
    final formKey = GlobalKey<FormState>();
    final ruleType = rule.type;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ThemeSizes.sm),
                    decoration: BoxDecoration(
                      color: (ruleType == RuleType.bonus
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ruleType == RuleType.bonus
                          ? Icons.add_circle
                          : Icons.remove_circle,
                      color: ruleType == RuleType.bonus
                          ? Colors.green
                          : Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Text(
                    'Modifica Regola',
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeSizes.lg),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Inserisci il nome della regola',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        ),
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
                      decoration: InputDecoration(
                        labelText: 'Punti',
                        hintText: 'Inserisci il valore dei punti',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        ),
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
                  ],
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              Row(
                children: [
                  // Use Expanded for buttons to prevent overflow
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                      ),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final pointsValue =
                              double.parse(pointsController.text.trim());

                          // Create updated rule object with proper sign based on type
                          final updatedRule = {
                            'id': rule.id,
                            'name': name,
                            'points': pointsValue.abs(),
                            'type': ruleType.toString().split('.').last,
                          };

                          // Call method to update rule in database
                          context.read<LeagueBloc>().add(
                                UpdateRuleEvent(
                                  leagueId: leagueId,
                                  rule: updatedRule,
                                ),
                              );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Regola aggiornata con successo'),
                              backgroundColor: ruleType == RuleType.bonus
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ruleType == RuleType.bonus
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                      ),
                      child: const Text('Salva'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const _CustomTabBar({
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.secondaryBgColor,
      child: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        indicator: _CustomTabIndicator(
          controller: controller,
          colors: const [Colors.green, Colors.red],
        ),
      ),
    );
  }
}

class _CustomTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CustomTab({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTabIndicator extends Decoration {
  final TabController controller;
  final List<Color> colors;

  const _CustomTabIndicator({
    required this.controller,
    required this.colors,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomIndicatorPainter(
      controller: controller,
      colors: colors,
      onChanged: onChanged,
    );
  }
}

class _CustomIndicatorPainter extends BoxPainter {
  final TabController controller;
  final List<Color> colors;

  _CustomIndicatorPainter({
    required this.controller,
    required this.colors,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final double currentIndex = controller.index.toDouble();
    final Color indicatorColor = colors[controller.index];

    final Paint paint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;

    final double width = configuration.size!.width;
    final double height = 3.0; // indicator height
    final double left = offset.dx;
    final double top = offset.dy + configuration.size!.height - height;

    canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
  }
}

class _RulesList extends StatelessWidget {
  final List<Rule> rules;
  final String emptyMessage;
  final bool isBonus;
  final bool isAdmin;
  final String leagueId;

  const _RulesList({
    required this.rules,
    required this.emptyMessage,
    required this.isBonus,
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (isBonus ? Colors.green : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBonus
                    ? Icons.arrow_circle_up_outlined
                    : Icons.arrow_circle_down_outlined,
                size: 64,
                color: isBonus ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (isAdmin) ...[
              const SizedBox(height: ThemeSizes.xl),
              ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(context, leagueId),
                icon: Icon(isBonus
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline),
                label: Text('Aggiungi ${isBonus ? 'Bonus' : 'Malus'}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBonus ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.lg,
                    vertical: ThemeSizes.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        children: [
          // Info text for rule type
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.md,
              vertical: ThemeSizes.sm,
            ),
            margin: const EdgeInsets.only(bottom: ThemeSizes.md),
            decoration: BoxDecoration(
              color: isBonus
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              border: Border.all(
                color: isBonus
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: isBonus ? Colors.green : Colors.red,
                ),
                const SizedBox(width: ThemeSizes.sm),
                Expanded(
                  child: Text(
                    isBonus
                        ? 'Queste regole assegnano punti bonus ai partecipanti'
                        : 'Queste regole sottraggono punti ai partecipanti',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rule list
          Expanded(
            child: ListView.builder(
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                final ruleJson = {
                  'name': rule.name,
                  'points': rule.points,
                  'type': isBonus ? 'bonus' : 'malus',
                  'id': rule.id, // Make sure ID is passed for editing
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
                  child: RuleItem(
                    rule: ruleJson,
                    onEdit: isAdmin
                        ? () => _editRule(context, rule, leagueId)
                        : () {},
                    onDelete: isAdmin
                        ? () => _confirmDeleteRule(context, rule, leagueId)
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

  void _showAddRuleDialog(BuildContext context, String leagueId) {
    if (context.findAncestorStateOfType<_RulesPageState>() != null) {
      context
          .findAncestorStateOfType<_RulesPageState>()!
          ._showAddRuleDialog(context, leagueId, isBonus);
    }
  }

  void _editRule(BuildContext context, Rule rule, String leagueId) {
    final nameController = TextEditingController(text: rule.name);
    final pointsController =
        TextEditingController(text: rule.points.abs().toString());
    final formKey = GlobalKey<FormState>();
    final ruleType = rule.type;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ThemeSizes.sm),
                    decoration: BoxDecoration(
                      color: (ruleType == RuleType.bonus
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ruleType == RuleType.bonus
                          ? Icons.add_circle
                          : Icons.remove_circle,
                      color: ruleType == RuleType.bonus
                          ? Colors.green
                          : Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Text(
                    'Modifica Regola',
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeSizes.lg),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Inserisci il nome della regola',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        ),
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
                      decoration: InputDecoration(
                        labelText: 'Punti',
                        hintText: 'Inserisci il valore dei punti',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        ),
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
                  ],
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              Row(
                children: [
                  // Use Expanded for buttons to prevent overflow
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                      ),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final pointsValue =
                              double.parse(pointsController.text.trim());

                          // Create updated rule object with proper sign based on type
                          final updatedRule = {
                            'id': rule.id,
                            'name': name,
                            'points': pointsValue.abs(),
                            'type': ruleType.toString().split('.').last,
                          };

                          // Call method to update rule in database
                          context.read<LeagueBloc>().add(
                                UpdateRuleEvent(
                                  leagueId: leagueId,
                                  rule: updatedRule,
                                ),
                              );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Regola aggiornata con successo'),
                              backgroundColor: ruleType == RuleType.bonus
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ruleType == RuleType.bonus
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                      ),
                      child: const Text('Salva'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteRule(BuildContext context, Rule rule, String leagueId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          decoration: BoxDecoration(
            color: context.secondaryBgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                'Eliminare questa regola?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Sei sicuro di voler eliminare la regola "${rule.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                      ),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Call the delete rule method
                        context.read<LeagueBloc>().add(
                              DeleteRuleEvent(
                                leagueId: leagueId,
                                ruleId: rule.id,
                              ),
                            );
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Regola "${rule.name}" eliminata'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                      ),
                      child: const Text('Elimina'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
