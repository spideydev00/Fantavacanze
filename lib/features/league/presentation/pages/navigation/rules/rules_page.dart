import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rules/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const RulesPage());
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
        if (state is AppLeagueExists) {
          final league = state.selectedLeague;
          final isAdmin = context.read<LeagueBloc>().isAdmin();

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
                // Fixed header with tabs
                Container(
                  color: context.secondaryBgColor,
                  child: RuleTypeTabBar(
                    controller: _tabController,
                    indicatorColors: const [
                      ColorPalette.success,
                      ColorPalette.error
                    ],
                    tabs: const [
                      RuleTypeTab(
                        label: "BONUS",
                        icon: Icons.arrow_upward_rounded,
                        color: ColorPalette.success,
                      ),
                      RuleTypeTab(
                        label: "MALUS",
                        icon: Icons.arrow_downward_rounded,
                        color: ColorPalette.error,
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
                      RulesList(
                        rules: bonusRules,
                        emptyMessage: 'Nessuna regola bonus disponibile',
                        isBonus: true,
                        isAdmin: isAdmin,
                        league: league,
                        onAddPressed: _addRuleDirectly,
                        onDeleteRule: _showDeleteRuleConfirmation,
                      ),

                      // Malus rules tab
                      RulesList(
                        rules: malusRules,
                        emptyMessage: 'Nessuna regola malus disponibile',
                        isBonus: false,
                        isAdmin: isAdmin,
                        league: league,
                        onAddPressed: _addRuleDirectly,
                        onDeleteRule: _showDeleteRuleConfirmation,
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
                                _addRuleDirectly(context, league, isBonus),
                            backgroundColor: isBonus
                                ? ColorPalette.success
                                : ColorPalette.error,
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

  /// Display the rule form dialog directly without confirmation
  void _addRuleDirectly(BuildContext context, League league, [bool? isBonus]) {
    // Use the current tab to determine if bonus or malus if not explicitly provided
    final selectedTab = isBonus ?? _tabController.index == 0;

    // Use our RulesList component's internal method to show the add rule dialog
    final rulesList = RulesList(
      rules: const [], // Empty list, not used for this purpose
      emptyMessage: '', // Not used for this purpose
      isBonus: selectedTab,
      isAdmin: true,
      league: league,
    );

    rulesList.showAddRuleDialog(context, league);
  }

  /// Display a confirmation dialog before deleting a rule
  void _showDeleteRuleConfirmation(
      BuildContext context, League league, Rule rule) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.deleteRule(
        ruleName: rule.name,
        onDelete: () {
          // Dispatch delete rule event to the bloc
          context.read<LeagueBloc>().add(
                DeleteRuleEvent(
                  league: league,
                  ruleName: rule.name,
                ),
              );
        },
      ),
    );
  }
}
