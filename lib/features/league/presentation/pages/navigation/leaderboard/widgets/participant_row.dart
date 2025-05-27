import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/number_formatter.dart';
import 'package:flutter/material.dart';

class ParticipantRow extends StatelessWidget {
  final String name;
  final double points;
  final int position;
  final String? avatarUrl;
  final bool isTeam;

  const ParticipantRow({
    super.key,
    required this.name,
    required this.points,
    required this.position,
    this.avatarUrl,
    this.isTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format points using NumberFormatter
    final formattedPoints = NumberFormatter.formatPoints(points);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
      child: Row(
        children: [
          // Position indicator
          Text(
            '$position',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),

          // Avatar
          if (avatarUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl!),
              radius: 20,
            )
          else
            CircleAvatar(
              backgroundColor: context.secondaryBgColor,
              radius: 20,
              child: Icon(
                isTeam ? Icons.group : Icons.person,
                color: context.primaryColor,
              ),
            ),
          const SizedBox(width: ThemeSizes.md),

          // Name
          Expanded(
            child: Text(
              name,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Points
          Text(
            formattedPoints, // Use formatted points here
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
