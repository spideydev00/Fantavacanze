import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueDropdown extends StatefulWidget {
  const LeagueDropdown({super.key});

  @override
  State<LeagueDropdown> createState() => _LeagueDropdownState();
}

class _LeagueDropdownState extends State<LeagueDropdown> {
  final _vn = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _vn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
        builder: (context, appLeagueState) {
      // Mostra il dropdown solo quando esistono delle leghe
      if (appLeagueState is! AppLeagueExists) {
        return const SizedBox.shrink();
      }

      final leagues = appLeagueState.leagues;
      final selectedLeague = appLeagueState.selectedLeague;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomDivider(text: "Le Mie Leghe"),
            const SizedBox(height: ThemeSizes.xs),
            _buildLeagueSelector(
              context,
              leagues,
              selectedLeague,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLeagueSelector(
      BuildContext context, List<League> leagues, League selectedLeague) {
    // Deduplicazione per id: evita che due item abbiano lo stesso value.
    final uniqueLeagues = <String, League>{
      for (final l in leagues) l.id: l,
    }.values.toList();

    final leagueIds = uniqueLeagues.map((l) => l.id).toList();
    final safeValue = leagueIds.contains(selectedLeague.id)
        ? selectedLeague.id
        : (leagueIds.isNotEmpty ? leagueIds.first : null);

    if (safeValue == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.sm,
        ),
        decoration: BoxDecoration(
          color: context.bgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Text(
          "Nessuna lega disponibile",
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    if (_vn.value != safeValue) {
      _vn.value = safeValue;
    }

    return DropdownButton2<String>(
      valueListenable: _vn,
      onChanged: (String? newLeagueId) {
        if (newLeagueId != null) {
          final newLeague = uniqueLeagues.firstWhere(
            (league) => league.id == newLeagueId,
          );
          _vn.value = newLeagueId;
          context.read<AppLeagueCubit>().selectLeague(newLeague);
        }
      },

      items: uniqueLeagues.map<DropdownItem<String>>((League league) {
        return DropdownItem<String>(
          value: league.id,
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.group,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  league.name,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      }).toList(),

      selectedItemBuilder: (context) {
        return uniqueLeagues.map<Widget>((league) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              league.name,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList();
      },

      isExpanded: true,
      underline: const SizedBox(),

      // Stile del bottone con il nuovo bordo
      buttonStyleData: ButtonStyleData(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.xs,
        ),
        decoration: BoxDecoration(
          color: context.bgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: ColorPalette.darkGrey,
            width: 0.2,
          ),
        ),
      ),

      // Stile dell'icona a freccia
      iconStyleData: IconStyleData(
        icon: const Icon(Icons.arrow_drop_down),
        iconEnabledColor: context.textTheme.bodyMedium?.color,
      ),

      // Stile del menu a tendina
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          color: context.bgColor,
        ),
        offset: const Offset(0, -5),
      ),

      // Stile per gli elementi nel menu
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }
}
