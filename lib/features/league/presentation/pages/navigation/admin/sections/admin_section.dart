import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/find_admin_name.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminSection extends StatefulWidget {
  final League league;

  const AdminSection({
    super.key,
    required this.league,
  });

  @override
  State<AdminSection> createState() => _AdminSectionState();
}

class _AdminSectionState extends State<AdminSection> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is AdminOperationSuccess &&
            state.operation == 'add_administrators') {
          // Show success message
          showSnackBar(
            "Amministratori aggiunti con successo!",
            color: ColorPalette.success,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeSizes.lg),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            _buildAdminInfoCard(),
            Padding(
              padding: const EdgeInsets.only(
                left: ThemeSizes.sm,
                right: ThemeSizes.sm,
                top: ThemeSizes.md,
              ),
              child: _buildAdminsList(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: ThemeSizes.md,
                  left: ThemeSizes.md,
                  right: ThemeSizes.md,
                ),
                child: ElevatedButton.icon(
                  onPressed: _showAddAdminDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Aggiungi Amministratore'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.textPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: context.textSecondaryColor.withValues(alpha: 0.8),
              size: 22,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Text(
            'Amministratori',
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.sm + 4),
      child: InfoContainer(
        icon: Icons.error_outline_sharp,
        title: "Amministratori",
        message:
            "Gli amministratori hanno accesso completo alla gestione della lega, inclusa la modifica delle regole, l'aggiunta di eventi e la gestione dei partecipanti.",
        color: context.primaryColor,
      ),
    );
  }

  Widget _buildAdminsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.league.admins.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final adminId = widget.league.admins[index];

        // Find the participant data for this admin ID
        String adminName = "Admin";

        // Search for admin in participants
        adminName = findAdminName(widget.league, adminId);

        // Build each admin list item without checkboxes
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.2),
              child: Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: context.textTheme.titleMedium!.copyWith(
                  color: context.primaryColor,
                ),
              ),
            ),
            title: Text(
              adminName,
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Amministratore',
              style: context.textTheme.bodySmall!.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            trailing: Icon(
              Icons.admin_panel_settings_outlined,
              color: context.primaryColor,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  void _showAddAdminDialog() {
    final List<String> selectedParticipants = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmationDialog(
              title: "Aggiungi Amministratori",
              message:
                  "Seleziona i partecipanti che desideri promuovere ad amministratori della lega.",
              icon: Icons.admin_panel_settings,
              iconColor: context.primaryColor,
              confirmText: "Aggiungi",
              additionalContent: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final participant in widget.league.participants)
                      ..._buildParticipantItems(
                        participant,
                        selectedParticipants,
                        setState,
                      ),
                  ],
                ),
              ),
              onConfirm: () {
                if (selectedParticipants.isEmpty) {
                  showSnackBar(
                    "Seleziona almeno un partecipante da promuovere",
                    color: ColorPalette.error,
                  );
                  return;
                }

                // Add new admins
                context.read<LeagueBloc>().add(
                      AddAdministratorsEvent(
                        league: widget.league,
                        userIds: selectedParticipants,
                      ),
                    );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildParticipantItems(
    dynamic participant,
    List<String> selectedParticipants,
    StateSetter setState,
  ) {
    List<Widget> items = [];

    if (widget.league.isTeamBased) {
      if (participant is TeamParticipant) {
        // For team-based leagues, add each team member
        for (final member in participant.members) {
          // Don't show existing admins
          if (!widget.league.admins.contains(member.userId)) {
            items.add(
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: context.bgColor,
                  borderRadius: BorderRadius.circular(
                    ThemeSizes.borderRadiusLg,
                  ),
                ),
                child: CheckboxListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '(${participant.name})',
                        style: context.textTheme.labelSmall!.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  value: selectedParticipants.contains(member.userId),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        selectedParticipants.add(member.userId);
                      } else {
                        selectedParticipants.remove(member.userId);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor:
                        context.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      member.name[0].toUpperCase(),
                      style: context.textTheme.titleMedium!.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    } else {
      if (participant is IndividualParticipant) {
        // For individual leagues
        if (!widget.league.admins.contains(participant.userId)) {
          items.add(
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              ),
              child: CheckboxListTile(
                title: Text(participant.name),
                subtitle: const Text('Partecipante'),
                value: selectedParticipants.contains(participant.userId),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      selectedParticipants.add(participant.userId);
                    } else {
                      selectedParticipants.remove(participant.userId);
                    }
                  });
                },
                secondary: CircleAvatar(
                  backgroundColor: context.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    participant.name[0].toUpperCase(),
                    style: context.textTheme.titleMedium!.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return items;
  }
}
