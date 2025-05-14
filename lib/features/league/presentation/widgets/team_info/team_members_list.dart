import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamMembersList extends StatefulWidget {
  final TeamParticipant team;
  final List<String> admins;
  final String currentUserId;
  final bool isCaptain;
  final Function(bool isRemoving)? onRemovalModeChanged;

  const TeamMembersList({
    super.key,
    required this.team,
    required this.admins,
    required this.currentUserId,
    this.isCaptain = false,
    this.onRemovalModeChanged,
  });

  @override
  State<TeamMembersList> createState() => TeamMembersListState();
}

class TeamMembersListState extends State<TeamMembersList> {
  bool _isRemovingMembers = false;
  final Set<String> _selectedMembersToRemove = {};

  bool get isRemovingMembers => _isRemovingMembers;

  void toggleRemovalMode() {
    setState(() {
      _isRemovingMembers = !_isRemovingMembers;
      _selectedMembersToRemove.clear();
    });

    // Notify parent about the change
    if (widget.onRemovalModeChanged != null) {
      widget.onRemovalModeChanged!(_isRemovingMembers);
    }
  }

  void _toggleMemberSelection(String userId) {
    setState(() {
      if (_selectedMembersToRemove.contains(userId)) {
        _selectedMembersToRemove.remove(userId);
      } else {
        _selectedMembersToRemove.add(userId);
      }
    });
  }

  void _removeSelectedMembers() {
    if (_selectedMembersToRemove.isEmpty) {
      showSnackBar(context, 'Seleziona almeno un membro da rimuovere');
      return;
    }

    final leagueBloc = context.read<LeagueBloc>();
    final AppLeagueCubit leagueCubit = context.read<AppLeagueCubit>();
    final leagueState = leagueCubit.state;

    if (leagueState is AppLeagueExists) {
      leagueBloc.add(
        RemoveTeamParticipantsEvent(
          league: leagueState.selectedLeague,
          teamName: widget.team.name,
          userIdsToRemove: _selectedMembersToRemove.toList(),
        ),
      );

      // Reset state
      setState(() {
        _isRemovingMembers = false;
        _selectedMembersToRemove.clear();
      });

      // Notify parent about the change
      if (widget.onRemovalModeChanged != null) {
        widget.onRemovalModeChanged!(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeagueBloc, LeagueState>(
      builder: (context, state) {
        return TeamMembersListContent(
          team: widget.team,
          admins: widget.admins,
          currentUserId: widget.currentUserId,
          isCaptain: widget.isCaptain,
          isRemovingMembers: _isRemovingMembers,
          selectedMembersToRemove: _selectedMembersToRemove,
          onToggleRemovalMode: toggleRemovalMode,
          onToggleMemberSelection: _toggleMemberSelection,
          onRemoveSelectedMembers: _removeSelectedMembers,
        );
      },
    );
  }
}

class TeamMembersListContent extends StatelessWidget {
  final TeamParticipant team;
  final List<String> admins;
  final String currentUserId;
  final bool isCaptain;
  final bool isRemovingMembers;
  final Set<String> selectedMembersToRemove;
  final VoidCallback onToggleRemovalMode;
  final void Function(String userId) onToggleMemberSelection;
  final VoidCallback onRemoveSelectedMembers;

  const TeamMembersListContent({
    super.key,
    required this.team,
    required this.admins,
    required this.currentUserId,
    this.isCaptain = false,
    this.isRemovingMembers = false,
    required this.selectedMembersToRemove,
    required this.onToggleRemovalMode,
    required this.onToggleMemberSelection,
    required this.onRemoveSelectedMembers,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = admins.contains(currentUserId);
    final canManageMembers = isAdmin || isCaptain;

    if (team.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Text(
            'Nessun membro nel team',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Pulsante per confermare la rimozione (mostrato solo in modalità rimozione)
        if (isRemovingMembers && selectedMembersToRemove.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: ElevatedButton.icon(
              onPressed: onRemoveSelectedMembers,
              icon: const Icon(Icons.delete),
              label: Text('Rimuovi ${selectedMembersToRemove.length} membri'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.error,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        // Lista dei membri
        ...List.generate(team.members.length, (index) {
          final member = team.members[index];
          final userId = member.userId;
          final name = member.name;
          final isUserAdmin = admins.contains(userId);
          final isCurrentUser = userId == currentUserId;
          final isUserCaptain = userId == team.captainId;

          // Se siamo in modalità rimozione e l'utente è l'admin corrente,
          // non permettere la selezione
          final canBeRemoved =
              !isRemovingMembers || (!isCurrentUser && canManageMembers);

          return _buildMemberItem(
            context,
            userId: userId,
            name: name,
            isAdmin: isUserAdmin,
            isCurrentUser: isCurrentUser,
            isCaptain: isUserCaptain,
            isSelected: selectedMembersToRemove.contains(userId),
            isRemovingMembers: isRemovingMembers,
            onToggleMemberSelection: onToggleMemberSelection,
            canBeRemoved: canBeRemoved &&
                !isUserAdmin &&
                !isUserCaptain, // Neither admins nor captains can be removed
          );
        }),
      ],
    );
  }

  Widget _buildMemberItem(
    BuildContext context, {
    required String userId,
    required String name,
    required bool isAdmin,
    required bool isCurrentUser,
    required bool isSelected,
    required bool isRemovingMembers,
    required void Function(String userId) onToggleMemberSelection,
    required bool canBeRemoved,
    required bool isCaptain,
  }) {
    return GestureDetector(
      onTap: (isRemovingMembers && canBeRemoved)
          ? () => onToggleMemberSelection(userId)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
        padding: const EdgeInsets.all(ThemeSizes.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.2)
              : context.bgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: isRemovingMembers && !canBeRemoved
              ? Border.all(color: Colors.grey.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            // Checkbox per la selezione (visibile solo in modalità rimozione)
            if (isRemovingMembers)
              Padding(
                padding: const EdgeInsets.only(right: ThemeSizes.sm),
                child: canBeRemoved
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (value) => onToggleMemberSelection(userId),
                        activeColor: context.primaryColor,
                      )
                    : const SizedBox(
                        width: 24, height: 24), // Spazio per allineamento
              ),

            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? context.primaryColor.withValues(alpha: 0.2)
                    : context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(width: ThemeSizes.md),

            // Informazioni sul membro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$name  ${isCurrentUser ? '(Tu)' : ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                      decoration: isRemovingMembers && !canBeRemoved
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey,
                      decorationThickness: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        // Use a helper method to determine the role text
                        _getUserRoleText(isAdmin, isCaptain),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      SizedBox(width: ThemeSizes.xs),
                      Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: ColorPalette.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge for Admin or Captain
            if (isAdmin || isCaptain)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.sm,
                  vertical: ThemeSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Text(
                  isAdmin ? 'Admin' : 'Captain',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ),

            // Tooltip for why user can't be removed
            if (isRemovingMembers && !canBeRemoved)
              Tooltip(
                message: isCurrentUser
                    ? 'Non puoi rimuovere te stesso'
                    : isAdmin
                        ? 'Non puoi rimuovere un admin'
                        : isCaptain
                            ? 'Non puoi rimuovere il captain'
                            : 'Non puoi rimuovere questo utente',
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: context.textSecondaryColor.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine the appropriate role text
  String _getUserRoleText(bool isAdmin, bool isCaptain) {
    if (isAdmin && isCaptain) {
      return 'Admin & Captain';
    } else if (isAdmin) {
      return 'Admin';
    } else if (isCaptain) {
      return 'Captain';
    } else {
      return 'Membro';
    }
  }
}
