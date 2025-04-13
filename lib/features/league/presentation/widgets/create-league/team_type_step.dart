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
        _buildInfoBox(context),
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
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return context.primaryColor;
              }
              return Colors.grey;
            }),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            children: [
              ListTile(
                title: const Text('Lega Individuale'),
                subtitle:
                    const Text('I partecipanti competono individualmente'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: isTeamBased,
                  onChanged: (value) {
                    if (value != null) onTeamTypeChanged(value);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Lega a Squadre'),
                subtitle: const Text('I partecipanti competono in squadre'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: isTeamBased,
                  onChanged: (value) {
                    if (value != null) onTeamTypeChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: context.primaryColor,
          ),
          const SizedBox(width: ThemeSizes.sm),
          Expanded(
            child: Text(
              isTeamBased
                  ? 'In una lega a squadre, i partecipanti possono unirsi a squadre e competere insieme.'
                  : 'In una lega individuale, ogni partecipante compete per sé stesso.',
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
