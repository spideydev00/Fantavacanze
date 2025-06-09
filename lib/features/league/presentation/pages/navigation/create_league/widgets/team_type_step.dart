import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

class TeamTypeStep extends StatelessWidget {
  final bool isTeamBased;
  final ValueChanged<bool> onTeamTypeChanged;

  const TeamTypeStep({
    super.key,
    required this.isTeamBased,
    required this.onTeamTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo di Lega',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        _buildTeamTypeSelector(context),
        const SizedBox(height: ThemeSizes.lg),
        isTeamBased
            ? InfoContainer(
                title: "A squadre",
                message:
                    "In una lega a squadre, i partecipanti formano delle squadre per competere insieme.",
                icon: Icons.info_outline,
                color: ColorPalette.warning,
              )
            : InfoContainer(
                title: "Individuale",
                message:
                    "In una lega individuale, ogni partecipante compete per sé stesso.",
                icon: Icons.info_outline,
                color: ColorPalette.warning,
              )
      ],
    );
  }

  Widget _buildTeamTypeSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return context.primaryColor;
                }
                return ColorPalette.darkGrey;
              },
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            children: [
              // Individual league option
              _TeamTypeOption(
                title: 'Lega Individuale',
                description: 'Ogni partecipante gioca per sé',
                isSelected: !isTeamBased,
                value: false,
                groupValue: isTeamBased,
                onChanged: onTeamTypeChanged,
              ),

              CustomDivider(text: 'Oppure'),

              // Team league option
              _TeamTypeOption(
                title: 'Lega a Squadre',
                description: 'I partecipanti competono in squadre',
                isSelected: isTeamBased,
                value: true,
                groupValue: isTeamBased,
                onChanged: onTeamTypeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Private reusable component for team type options
class _TeamTypeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final bool value;
  final bool groupValue;
  final ValueChanged<bool> onChanged;

  const _TeamTypeOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(ThemeSizes.sm),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              activeColor: context.primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.xs),
                  Text(
                    description,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
