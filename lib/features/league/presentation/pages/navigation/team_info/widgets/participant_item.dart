import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/profile_image_avatar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantItem extends StatelessWidget {
  final Participant participant;

  const ParticipantItem({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildAvatar(context),
        title: Text(participant.name),
        subtitle: _buildSubtitle(),
        trailing: _buildScoreBadge(),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (participant is IndividualParticipant) {
      final individualParticipant = participant as IndividualParticipant;
      final profileImageUrl = context
          .watch<AppLeagueCubit>()
          .getProfileImageFor(individualParticipant.userId);

      return ProfileImageAvatar(
        imageUrl: profileImageUrl,
        size: 40,
        loaderColor: Colors.white,
        fallback: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: ColorPalette.getGradientFromId(
              individualParticipant.userId,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            individualParticipant.name.isNotEmpty
                ? individualParticipant.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (participant is TeamParticipant) {
      final teamParticipant = participant as TeamParticipant;
      final teamLogoUrl = teamParticipant.teamLogoUrl;

      if (teamLogoUrl != null) {
        return CircleAvatar(
          backgroundImage: NetworkImage(teamLogoUrl),
        );
      } else {
        return CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: const Icon(
            Icons.group,
            color: Colors.orange,
          ),
        );
      }
    }

    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }

  Widget _buildSubtitle() {
    if (participant is TeamParticipant) {
      final teamParticipant = participant as TeamParticipant;
      final memberCount = teamParticipant.userIds.length;
      return Text('$memberCount ${memberCount == 1 ? 'member' : 'members'}');
    }
    return const Text('Participant');
  }

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${participant.points} pts',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    );
  }
}
