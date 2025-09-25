import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/modern_icon_button.dart';
import 'package:flutter/material.dart';

class FsNavigationButtons extends StatelessWidget {
  const FsNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ModernIconButton(
          icon: Icons.home_rounded,
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: ColorPalette.fsGradients),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorPalette.fsGradients.first.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ModernIconButton(
            icon: Icons.dashboard_rounded,
            onTap: () {
              // TODO: Navigate to FS dashboard when implemented
              showSpecificSnackBar(
                context,
                'Dashboard FantaSerata in arrivo!',
                color: ColorPalette.info,
              );
            },
          ),
        ),
      ],
    );
  }
}
