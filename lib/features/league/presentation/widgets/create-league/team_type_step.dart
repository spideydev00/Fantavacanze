import 'package:fantavacanze_official/core/theme/colors.dart';
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
              const Divider(
                thickness: 0.2,
              ),
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
}
