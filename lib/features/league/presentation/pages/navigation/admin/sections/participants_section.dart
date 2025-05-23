import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/icon_label.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/widgets/admin_section_card.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantsSection extends StatefulWidget {
  final League league;

  const ParticipantsSection({super.key, required this.league});

  @override
  State<ParticipantsSection> createState() => ParticipantsSectionState();
}

class ParticipantsSectionState extends State<ParticipantsSection> {
  final List<String> _selectedParticipantIds = [];
  bool _isSelectionMode = false;
  String? _selectedTeamName; // Track which team has selected members

  // Calculate if there are any removable participants
  bool get _hasRemovableParticipants {
    // For team-based leagues
    if (widget.league.isTeamBased) {
      for (final participant in widget.league.participants) {
        if (participant is TeamParticipant) {
          for (final member in participant.members) {
            if (!widget.league.admins.contains(member.userId)) {
              return true;
            }
          }
        }
      }
    } else {
      // For individual-based leagues
      for (final participant in widget.league.participants) {
        if (participant is IndividualParticipant) {
          if (!widget.league.admins.contains(participant.userId)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      title: 'Partecipanti',
      icon: Icons.people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description text
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Text(
              'Gestisci i partecipanti della tua lega. Puoi selezionare più partecipanti per rimuoverli contemporaneamente.',
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),

          // Selection mode toggle - only show if there are removable participants
          if (_hasRemovableParticipants)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemeSizes.md,
                ThemeSizes.sm,
                ThemeSizes.md,
                ThemeSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Participant count badge
                  IconLabel(
                    text: '${widget.league.participants.length} partecipanti',
                    icon: Icons.people,
                  ),

                  // Selection mode toggle button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = !_isSelectionMode;
                        if (!_isSelectionMode) {
                          _selectedParticipantIds.clear();
                          _selectedTeamName = null; // Reset selected team
                        }
                      });
                    },
                    icon: Icon(
                      _isSelectionMode
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _isSelectionMode
                          ? context.primaryColor
                          : context.textSecondaryColor,
                    ),
                    label: Text(
                      _isSelectionMode ? 'Esci dalla selezione' : 'Seleziona',
                      style: context.textTheme.labelLarge!.copyWith(
                        color: _isSelectionMode
                            ? context.secondaryColor
                            : context.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.sm,
                        vertical: 6,
                      ),
                      backgroundColor: _isSelectionMode
                          ? context.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        side: _isSelectionMode
                            ? BorderSide(color: context.primaryColor)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Participants list
          widget.league.isTeamBased
              ? _buildTeamsList()
              : _buildIndividualsList(),

          // Display "Remove" button at the bottom when in selection mode with participants selected
          if (_isSelectionMode && _selectedParticipantIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: ElevatedButton.icon(
                onPressed: _showRemoveParticipantsDialog,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 22,
                ),
                label: Text(
                    'Rimuovi ${_selectedParticipantIds.length} Partecipanti'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    final teams =
        widget.league.participants.whereType<TeamParticipant>().toList();

    if (teams.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(ThemeSizes.md),
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: context.primaryColor,
              size: 20,
            ),
            const SizedBox(width: ThemeSizes.sm),
            const Text('Nessun team partecipante'),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ThemeSizes.md),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        // Determine if this team is selectable
        final bool isTeamSelectable =
            _selectedTeamName == null || _selectedTeamName == team.name;

        return Opacity(
          opacity: isTeamSelectable ? 1.0 : 0.5,
          child: Card(
            margin: const EdgeInsets.only(bottom: ThemeSizes.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team header
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.primaryColor.withValues(alpha: 0.7),
                        context.primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(ThemeSizes.borderRadiusMd),
                      topRight: Radius.circular(ThemeSizes.borderRadiusMd),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: team.teamLogoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  team.teamLogoUrl!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(
                                      Icons.groups,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.groups,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                      ),
                      const SizedBox(width: ThemeSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${team.members.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Team members
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: team.members.length,
                  itemBuilder: (context, memberIndex) {
                    final member = team.members[memberIndex];
                    final userId = member.userId;
                    final isCaptain = team.captainId == userId;
                    final isAdmin = widget.league.admins.contains(userId);

                    return Container(
                      color: context.bgColor,
                      child: ListTile(
                        leading: _isSelectionMode && !isAdmin
                            ? Checkbox(
                                activeColor: context.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                value: _selectedParticipantIds.contains(userId),
                                onChanged: isTeamSelectable
                                    ? (value) {
                                        setState(() {
                                          if (value == true) {
                                            // If selecting first member, set this as the selected team
                                            _selectedTeamName == null
                                                ? _selectedTeamName = team.name
                                                : _selectedParticipantIds
                                                    .add(userId);
                                          } else {
                                            _selectedParticipantIds
                                                .remove(userId);
                                            // If no members from this team remain selected, clear team selection
                                            bool stillHasSelectedMembers =
                                                false;
                                            for (final m in team.members) {
                                              if (_selectedParticipantIds
                                                  .contains(m.userId)) {
                                                stillHasSelectedMembers = true;
                                                break;
                                              }
                                            }
                                            if (!stillHasSelectedMembers) {
                                              _selectedTeamName = null;
                                            }
                                          }
                                        });
                                      }
                                    : null, // Disable checkbox if team not selectable
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCaptain
                                      ? context.primaryColor
                                          .withValues(alpha: 0.2)
                                      : context.secondaryBgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCaptain
                                        ? context.primaryColor
                                        : context.borderColor
                                            .withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isCaptain ? Icons.shield : Icons.person,
                                    color: isCaptain
                                        ? context.primaryColor
                                        : context.textSecondaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                        title: Row(
                          children: [
                            Text(
                              member.name,
                              style: context.textTheme.bodyMedium!.copyWith(
                                fontWeight: isCaptain
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isAdmin)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPalette.success.withAlpha(40),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: ColorPalette.success.withAlpha(100),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      color: ColorPalette.success,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Admin',
                                      style: context.textTheme.labelSmall!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ColorPalette.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        subtitle: isCaptain
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.shield,
                                    size: 14,
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Capitano del team',
                                    style:
                                        context.textTheme.labelMedium!.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndividualsList() {
    final individuals =
        widget.league.participants.whereType<IndividualParticipant>().toList();

    if (individuals.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(ThemeSizes.md),
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: context.primaryColor,
              size: 20,
            ),
            const SizedBox(width: ThemeSizes.sm),
            const Text('Nessun partecipante individuale'),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: individuals.length,
          itemBuilder: (context, index) {
            final participant = individuals[index];
            final userId = participant.userId;
            final isAdmin = widget.league.admins.contains(userId);

            return Container(
              color: context.bgColor,
              child: ListTile(
                leading: _isSelectionMode && !isAdmin
                    ? Checkbox(
                        activeColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        value: _selectedParticipantIds.contains(userId),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedParticipantIds.add(userId);
                            } else {
                              _selectedParticipantIds.remove(userId);
                            }
                          });
                        },
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.primaryColor.withValues(alpha: 0.7),
                              context.primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                title: Row(
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (isAdmin)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.success.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorPalette.success.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: ColorPalette.success,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Admin',
                              style: context.textTheme.labelSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRemoveParticipantsDialog() {
    if (_selectedParticipantIds.isEmpty) return;

    // Check if a captain is being removed
    String? captainIdToRemove;
    TeamParticipant? affectedTeam;

    if (widget.league.isTeamBased) {
      for (final participant in widget.league.participants) {
        if (participant is TeamParticipant) {
          if (_selectedParticipantIds.contains(participant.captainId)) {
            captainIdToRemove = participant.captainId;
            affectedTeam = participant;
            break;
          }
        }
      }
    }

    // If a captain is being removed, show a special dialog
    if (captainIdToRemove != null && affectedTeam != null) {
      _showCaptainReplacementDialog(
        affectedTeam: affectedTeam,
        captainIdToRemove: captainIdToRemove,
      );
    } else {
      // Regular removal flow
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog.delete(
          itemType: 'Partecipanti',
          customMessage:
              'Sei sicuro di voler rimuovere i partecipanti selezionati dalla lega?',
          onDelete: () {
            _removeParticipants(_selectedParticipantIds);
          },
        ),
      );
    }
  }

  void _showCaptainReplacementDialog({
    required TeamParticipant affectedTeam,
    required String captainIdToRemove,
  }) {
    // Get potential new captains (team members excluding the one being removed)
    final potentialCaptains = affectedTeam.members
        .where((member) =>
            member.userId != captainIdToRemove &&
            !_selectedParticipantIds.contains(member.userId))
        .toList();

    if (potentialCaptains.isEmpty) {
      // If no potential captains, show an error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Impossibile Rimuovere il Capitano'),
          content: const Text(
              'Non è possibile rimuovere il capitano perché non ci sono altri membri nel team che possano prendere il suo posto.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Initial selection for captain
    String? selectedNewCaptainId =
        potentialCaptains.isNotEmpty ? potentialCaptains.first.userId : null;

    // Using ConfirmationDialog for captain selection
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmationDialog(
              title: 'Seleziona Nuovo Capitano',
              message:
                  'Stai rimuovendo il capitano del team. Seleziona un nuovo capitano per continuare:',
              icon: Icons.shield,
              iconColor: context.primaryColor,
              confirmText: 'Conferma',
              additionalContent: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Nuovo Capitano',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedNewCaptainId,
                  items: potentialCaptains
                      .map((member) => DropdownMenuItem<String>(
                            value: member.userId,
                            child: Text(member.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNewCaptainId = value;
                    });
                  },
                ),
              ),
              onConfirm: () {
                if (selectedNewCaptainId != null) {
                  _confirmRemoveWithNewCaptain(
                    selectedNewCaptainId!,
                    captainIdToRemove,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _confirmRemoveWithNewCaptain(
    String newCaptainId,
    String captainIdToRemove,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.delete(
        itemType: 'Partecipanti',
        customMessage:
            'Sei sicuro di voler rimuovere i partecipanti selezionati e nominare un nuovo capitano?',
        onDelete: () {
          context.read<LeagueBloc>().add(
                RemoveParticipantsEvent(
                  league: widget.league,
                  participantIds: _selectedParticipantIds,
                  newCaptainId: newCaptainId,
                ),
              );
        },
      ),
    );
  }

  void _removeParticipants(List<String> participantIds) {
    if (participantIds.isNotEmpty) {
      context.read<LeagueBloc>().add(
            RemoveParticipantsEvent(
              league: widget.league,
              participantIds: participantIds,
            ),
          );
    }
  }

  /// Pulisce la selezione al termine dell’operazione
  void clearSelection() {
    setState(() {
      _selectedParticipantIds.clear();
      _isSelectionMode = false;
      _selectedTeamName = null; // Reset selected team
    });
  }
}
