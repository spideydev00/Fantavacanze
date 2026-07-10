import 'package:fantavacanze_official/core/constants/game_mode.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/partner_destination_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/game_mode_selector.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/widgets/rule_item.dart';
import 'package:flutter/material.dart';

class RulesStep extends StatelessWidget {
  final GameMode? selectedRuleMode;
  final bool isLoadingRules;
  final bool rulesLoaded;
  final List<Rule> rules;
  final Function(GameMode) onRuleModeChanged;
  final VoidCallback onAddRule;
  final Function(int) onEditRule;
  final Function(int) onRemoveRule;
  final ScrollController? scrollController;
  final String packagePartnerSlug;
  final List<PartnerDestination> packageDestinations;
  final bool isLoadingPackageDestinations;
  final String? selectedPartnerDestinationId;
  final ValueChanged<PartnerDestination> onPartnerDestinationSelected;

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
    required this.packagePartnerSlug,
    required this.packageDestinations,
    required this.isLoadingPackageDestinations,
    required this.selectedPartnerDestinationId,
    required this.onPartnerDestinationSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingPackageDestinations ||
              packageDestinations.isNotEmpty) ...[
            const SizedBox(height: ThemeSizes.lg),
            _PackageDestinationsSection(
              partnerSlug: packagePartnerSlug,
              destinations: packageDestinations,
              isLoading: isLoadingPackageDestinations,
              selectedDestinationId: selectedPartnerDestinationId,
              onDestinationSelected: onPartnerDestinationSelected,
            ),
          ],
          const SizedBox(height: ThemeSizes.lg),
          Text(
            'I Nostri Regolamenti',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            'Una volta selezionato un regolamento puoi vedere le singole regole in fondo a questa pagina ed eventualmente fare modifiche.',
            style: context.textTheme.bodyMedium,
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
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Loader(color: context.primaryColor),
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
                color: ColorPalette.success,
                size: ThemeSizes.iconLg,
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
            'Clicca sul pulsante + per aggiungere regole alla tua lega. Ti consigliamo di assegnare punteggi tra 2 e 15 per la migliore esperienza utente possibile.',
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

class _PackageDestinationsSection extends StatelessWidget {
  final String partnerSlug;
  final List<PartnerDestination> destinations;
  final bool isLoading;
  final String? selectedDestinationId;
  final ValueChanged<PartnerDestination> onDestinationSelected;

  const _PackageDestinationsSection({
    required this.partnerSlug,
    required this.destinations,
    required this.isLoading,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(partnerSlug);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pacchetti Partner',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        if (isLoading)
          Center(child: Loader(color: brandColor))
        else
          for (final destination in destinations)
            PartnerDestinationCard(
              name: destination.name,
              description: destination.description,
              imageUrl: destination.imageUrl,
              accentColor: brandColor,
              tagLabel: _roundDateLabel(destination),
              selected: destination.id == selectedDestinationId,
              onTap: () => onDestinationSelected(destination),
            ),
      ],
    );
  }

  String? _roundDateLabel(PartnerDestination destination) {
    if (destination.rounds.isEmpty) return null;
    final round = destination.rounds.first;
    final start = _formatDate(round.startDate);
    final end = round.endDate == null ? null : _formatDate(round.endDate!);
    return end == null ? 'Turno dal $start' : 'Turno $start - $end';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}
