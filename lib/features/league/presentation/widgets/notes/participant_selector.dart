import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:flutter/material.dart';

class ParticipantSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;
  final Widget Function(T) itemBuilder;
  final String hintText;
  final IconData prefixIcon;
  final double height;
  final ButtonStyleData? buttonStyleData;
  final DropdownStyleData? dropdownStyleData;
  final double maxDropdownHeight;

  const ParticipantSelector({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemBuilder,
    this.hintText = 'Seleziona',
    this.prefixIcon = Icons.groups_rounded,
    this.height = 50,
    this.buttonStyleData,
    this.dropdownStyleData,
    this.maxDropdownHeight = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        hint: Row(
          children: [
            Icon(
              prefixIcon,
              size: 22,
              color: context.primaryColor,
            ),
            const SizedBox(width: ThemeSizes.sm),
            Expanded(
              child: Text(
                hintText,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: itemBuilder(item),
          );
        }).toList(),
        value: value,
        onChanged: onChanged,
        buttonStyleData: buttonStyleData ??
            ButtonStyleData(
              height: height,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
                border: Border.all(
                  color: Colors.black26.withValues(alpha: 0.1),
                ),
                color: context.secondaryBgColor,
              ),
            ),
        dropdownStyleData: dropdownStyleData ??
            DropdownStyleData(
              maxHeight: Constants.getHeight(context) * maxDropdownHeight,
              elevation: 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
                color: context.secondaryBgColor,
              ),
            ),
        menuItemStyleData: const MenuItemStyleData(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: ThemeSizes.md),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: context.textPrimaryColor,
          ),
          iconSize: 24,
        ),
      ),
    );
  }

  static Widget defaultParticipantItem(
      BuildContext context, Participant participant) {
    return Row(
      children: [
        Icon(
          Icons.arrow_right_rounded,
          size: 18,
          color: context.primaryColor,
        ),
        const SizedBox(width: ThemeSizes.xs),
        Expanded(
          child: Text(
            participant.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  static Widget defaultTeamMemberItem(
    BuildContext context, {
    required String userId,
    required String name,
  }) {
    return Row(
      children: [
        Icon(
          Icons.arrow_right_rounded,
          size: 16,
          color: context.primaryColor,
        ),
        const SizedBox(width: ThemeSizes.xs),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
