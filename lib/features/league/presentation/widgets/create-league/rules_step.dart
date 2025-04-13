import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/rule_item.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/create-league/rule_mode_selector.dart';

class RulesStep extends StatelessWidget {
  final RuleMode selectedRuleMode;
  final bool isLoadingRules;
  final bool rulesLoaded;
  final List<Map<String, dynamic>> rules;
  final Function(RuleMode) onRuleModeChanged;
  final VoidCallback onAddRule;
  final Function(int) onEditRule;
  final Function(int) onRemoveRule;
  final ScrollController? scrollController; // New parameter

  const RulesStep({
    super.key,
    required this.selectedRuleMode,
    required this.isLoadingRules,
    required this.rulesLoaded,
    required this.rules,
    required this.onRuleModeChanged,
    required this.onAddRule,
    required this.onEditRule,
    required this.onRemoveRule,
    this.scrollController, // Optional to maintain backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modalità Regole',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          RuleModeSelector(
            selectedMode: selectedRuleMode,
            isLoading: isLoadingRules,
            onModeChanged: onRuleModeChanged,
          ),
          const SizedBox(height: ThemeSizes.lg),
          if (isLoadingRules)
            _buildLoadingIndicator(context)
          else if (rulesLoaded)
            _buildRulesList(context),
          const SizedBox(
              height: 80), // Matches the height of the buttons container
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: context.primaryColor),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Caricamento regole...',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Regole della Lega',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onAddRule,
              icon: Icon(
                Icons.add_circle,
                color: context.primaryColor,
              ),
              tooltip: 'Aggiungi Regola',
            ),
          ],
        ),
        const SizedBox(height: ThemeSizes.sm),
        if (rules.isEmpty)
          _buildEmptyRulesMessage(context)
        else
          _buildRulesListView(),
        const SizedBox(height: ThemeSizes.md),
      ],
    );
  }

  Widget _buildEmptyRulesMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rule,
            size: 48,
            color: context.textSecondaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Nessuna regola aggiunta',
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'Clicca sul pulsante + per aggiungere regole alla tua lega.',
            style: TextStyle(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRulesListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        return RuleItem(
          rule: rules[index],
          onEdit: () => onEditRule(index),
          onDelete: () => onRemoveRule(index),
        );
      },
    );
  }
}
