import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';

/// A reusable tab component for rule types (bonus/malus)
///
/// This component displays a tab with an icon and a label,
/// customized for rule types in the app.
class RuleTypeTab extends StatelessWidget {
  /// The label text to display in the tab
  final String label;

  /// The icon to display next to the label
  final IconData icon;

  /// The color of the icon (usually green for bonus, red for malus)
  final Color color;

  /// Optional text style for the label
  final TextStyle? textStyle;

  /// Optional icon size
  final double iconSize;

  /// Optional spacing between icon and label
  final double spacing;

  const RuleTypeTab({
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
