import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
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

  const TeamMembersList({
    super.key,
    required this.team,
    required this.admins,
    required this.currentUserId,
  });

  @override
  State<TeamMembersList> createState() => _TeamMembersListState();
}

class _TeamMembersListState extends State<TeamMembersList> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _memberDetails;

  @override
  void initState() {
    super.initState();
    _fetchMemberDetails();
  }

  void _fetchMemberDetails() {
    if (widget.team.userIds.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Recupera i dettagli degli utenti tramite il bloc
    context.read<LeagueBloc>().add(
          GetUsersDetailsEvent(userIds: widget.team.userIds),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is UsersDetailsLoaded) {
          setState(() {
            _memberDetails = state.usersDetails;
            _isLoading = false;
          });
        } else if (state is LeagueError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: ${state.message}')),
          );
        }
      },
      child: TeamMembersListContent(
        team: widget.team,
        admins: widget.admins,
        currentUserId: widget.currentUserId,
        isLoadingMembers: _isLoading,
        memberDetails: _memberDetails,
      ),
    );
  }
}

class TeamMembersListContent extends StatelessWidget {
  final TeamParticipant team;
  final List<String> admins;
  final String currentUserId;
  final bool isLoadingMembers;
  final List<Map<String, dynamic>>? memberDetails;

  const TeamMembersListContent({
    super.key,
    required this.team,
    required this.admins,
    required this.currentUserId,
    this.isLoadingMembers = false,
    this.memberDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMembers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(ThemeSizes.md),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (team.userIds.isEmpty) {
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
        // Visualizza ciascun membro del team
        ...List.generate(team.userIds.length, (index) {
          final userId = team.userIds[index];
          final isAdmin = admins.contains(userId);
          final isCurrentUser = userId == currentUserId;

          // Trova i dettagli dell'utente, se disponibili
          String? userName;
          bool? isPremium;

          if (memberDetails != null) {
            final userDetail = memberDetails!.firstWhere(
              (member) => member['id'] == userId,
              orElse: () => {'name': 'Utente ${index + 1}'},
            );

            userName = userDetail['name'];
            isPremium = userDetail['is_premium'];
          }

          return _buildMemberItem(
            context,
            userId: userId,
            name: userName ?? 'Utente ${index + 1}',
            isAdmin: isAdmin,
            isCurrentUser: isCurrentUser,
            isPremium: isPremium ?? false,
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
    required bool isPremium,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      padding: const EdgeInsets.all(ThemeSizes.sm),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? context.primaryColor.withValues(alpha: 0.2)
                  : isPremium
                      ? ColorPalette.premiumUser.withValues(alpha: 0.2)
                      : context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color:
                  isPremium ? ColorPalette.premiumUser : context.primaryColor,
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
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      isAdmin ? 'Admin' : 'Membro',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: ColorPalette.premiumUser,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorPalette.premiumUser,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Badge Admin
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.sm,
                vertical: ThemeSizes.xs,
              ),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
