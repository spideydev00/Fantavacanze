import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/divider.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueDropdown extends StatelessWidget {
  const LeagueDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppLeagueCubit, AppLeagueState>(
      listener: (context, state) {},
      builder: (context, leagueState) {
        if (leagueState is AppLeagueExists) {
          if (leagueState.leagues.isEmpty) {
            return const SizedBox.shrink();
          }

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
                _buildLeagueSelector(
                  context,
                  leagueState.leagues,
                  leagueState.selectedLeague!,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLeagueSelector(
      BuildContext context, List<League> leagues, League selectedLeague) {
    // Check if the selected league exists in the leagues list
    final leagueIds = leagues.map((l) => l.id).toSet();
    final validSelection = leagueIds.contains(selectedLeague.id);

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
      child: DropdownButton<String>(
        value: validSelection
            ? selectedLeague.id
            : (leagues.isNotEmpty ? leagues.first.id : null),
        onChanged: (String? newLeagueId) {
          if (newLeagueId != null) {
            final newLeague = leagues.firstWhere((l) => l.id == newLeagueId);
            context.read<AppLeagueCubit>().selectLeague(newLeague);
          }
        },
        items: leagues.map<DropdownMenuItem<String>>((League league) {
          return DropdownMenuItem<String>(
            value: league.id,
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
