import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsSuccessHeader extends StatelessWidget {
  final String leagueName;

  const FsSuccessHeader({
    super.key,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ci Siamo!',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ThemeSizes.sm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
            children: [
              const TextSpan(text: 'La tua lega '),
              TextSpan(
                text: leagueName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' è stata creata con successo!'),
            ],
          ),
        ),
      ],
    );
  }
}
