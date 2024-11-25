import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';

class CustomRichText extends StatelessWidget {
  final VoidCallback onPressed;
  final String initialText;
  final String richText;
  final Color richTxtColor;

  const CustomRichText({
    super.key,
    required this.onPressed,
    required this.initialText,
    required this.richText,
    required this.richTxtColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: RichText(
        text: TextSpan(
          text: initialText,
          style: context.textTheme.bodyLarge,
          children: [
            TextSpan(
              text: ' $richText',
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: richTxtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
