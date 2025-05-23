import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';

/// A reusable tab component with icon and label
///
/// This component displays a tab with an icon and a label
/// for a more attractive UI than the standard Tab.
class CustomTab extends StatelessWidget {
  /// The label text to display in the tab
  final String label;

  /// The icon to display next to the label
  final IconData icon;

  /// The color of the icon
  final Color color;

  /// Optional text style for the label
  final TextStyle? textStyle;

  /// Optional icon size
  final double iconSize;

  /// Optional spacing between icon and label
  final double spacing;

  const CustomTab({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.textStyle,
    this.iconSize = 16,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            label,
            style: textStyle ??
                TextStyle(
                  color: context.textPrimaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
