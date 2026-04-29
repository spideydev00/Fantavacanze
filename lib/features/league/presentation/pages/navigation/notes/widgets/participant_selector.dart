import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:flutter/material.dart';

class ParticipantSelector<T> extends StatefulWidget {
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
  State<ParticipantSelector<T>> createState() => _ParticipantSelectorState<T>();

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

class _ParticipantSelectorState<T> extends State<ParticipantSelector<T>> {
  late final ValueNotifier<T?> _vn;

  @override
  void initState() {
    super.initState();
    _vn = ValueNotifier<T?>(widget.value);
  }

  @override
  void didUpdateWidget(covariant ParticipantSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _vn.value = widget.value;
    }
  }

  @override
  void dispose() {
    _vn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        hint: Row(
          children: [
            Icon(
              widget.prefixIcon,
              size: 22,
              color: context.primaryColor,
            ),
            const SizedBox(width: ThemeSizes.sm),
            Expanded(
              child: Text(
                widget.hintText,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        items: widget.items.map((item) {
          return DropdownItem<T>(
            value: item,
            height: 50,
            child: widget.itemBuilder(item),
          );
        }).toList(),
        valueListenable: _vn,
        onChanged: (v) {
          _vn.value = v;
          widget.onChanged(v);
        },
        buttonStyleData: widget.buttonStyleData ??
            ButtonStyleData(
              height: widget.height,
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
        dropdownStyleData: widget.dropdownStyleData ??
            DropdownStyleData(
              maxHeight:
                  Constants.getHeight(context) * widget.maxDropdownHeight,
              elevation: 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
                color: context.secondaryBgColor,
              ),
            ),
        menuItemStyleData: const MenuItemStyleData(
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
}
