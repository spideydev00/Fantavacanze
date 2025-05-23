import 'package:fantavacanze_official/core/widgets/buttons/page_redirection_card.dart';
import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  final List<ActionButtonData> buttons;
  final double spacing;
  final MainAxisAlignment alignment;

  const ActionButtonsRow({
    super.key,
    required this.buttons,
    this.spacing = 20,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: List.generate(
        buttons.length * 2 - 1,
        (index) {
          // Return spacer for odd indices
          if (index.isOdd) {
            return SizedBox(width: spacing);
          }

          // Return button for even indices
          final buttonIndex = index ~/ 2;
          final button = buttons[buttonIndex];

          return PageRedirectionCard(
            title: button.title,
            icon: button.icon,
            onPressed: button.onPressed,
          );
        },
      ),
    );
  }
}

class ActionButtonData {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButtonData({
    required this.title,
    required this.icon,
    required this.onPressed,
  });
}
