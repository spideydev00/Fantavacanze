import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/divider.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueDropdown extends StatelessWidget {
  const LeagueDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, leagueState) {
        if (leagueState is AppLeagueExists) {
          if (leagueState.leagues.isEmpty) {
            return const SizedBox.shrink();
          }

          // Sort leagues by creation date (newest first)
          final sortedLeagues = List<League>.from(leagueState.leagues)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.md,
              vertical: ThemeSizes.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDivider(text: "Le Mie Leghe"),
                const SizedBox(height: ThemeSizes.xs),
                _buildLeagueSelector(context, sortedLeagues, leagueState),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLeagueSelector(
      BuildContext context, List<League> leagues, AppLeagueExists leagueState) {
    final selectedLeague = leagueState.selectedLeague ?? leagues.first;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.xs,
      ),
      decoration: BoxDecoration(
        color: context.bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButton<League>(
        value: selectedLeague,
        onChanged: (League? newValue) {
          if (newValue != null) {
            context.read<AppLeagueCubit>().selectLeague(newValue);
          }
        },
        items: leagues.map<DropdownMenuItem<League>>((League league) {
          return DropdownMenuItem<League>(
            value: league,
            child: Text(
              league.name,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: context.primaryColor,
        ),
        underline: const SizedBox(),
        style: context.textTheme.bodyMedium,
        dropdownColor: context.secondaryBgColor,
      ),
    );
  }
}
