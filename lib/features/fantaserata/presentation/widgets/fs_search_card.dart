import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:flutter/material.dart';

class FsSearchCard extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onSearch;

  const FsSearchCard({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.md),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: context.bgColor,
              hintText: hintText,
              hintStyle: TextStyle(
                color: context.textSecondaryColor,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.primaryColor,
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ColorPalette.fsGradients,
                  ),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusSm),
                ),
                child: IconButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      showSpecificSnackBar(
                        context,
                        'Inserisci un codice invito valido',
                        color: ColorPalette.warning,
                      );
                      return;
                    }
                    onSearch();
                  },
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
