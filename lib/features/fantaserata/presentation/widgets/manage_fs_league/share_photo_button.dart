import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/features/fantaserata/data/utils/winner_photo_util.dart';
import 'package:flutter/material.dart';

class SharePhotoButton extends StatelessWidget {
  final String photoUrl;
  final bool isLoading;

  const SharePhotoButton({
    super.key,
    required this.photoUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        gradient: LinearGradient(
          colors: [
            ColorPalette.info.withValues(alpha: 0.05),
            ColorPalette.info.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: ColorPalette.info.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        child: InkWell(
          onTap: isLoading ? () {} : () => _shareWinnerPhoto(context),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          splashColor: ColorPalette.info.withValues(alpha: 0.1),
          highlightColor: ColorPalette.info.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.info.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    color: ColorPalette.info,
                    size: 22,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Share",
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: ColorPalette.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Hai fino alle 7!",
                        maxLines: 2,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: ColorPalette.info.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareWinnerPhoto(BuildContext context) async {
    if (photoUrl.isEmpty) {
      showSnackBar(
        'Nessuna foto da condividere',
        color: ColorPalette.error,
      );
      return;
    }

    try {
      await WinnerPhotoUtil.sharePhotoFromUrl(photoUrl);
    } catch (e) {
      showSnackBar(
        'Errore durante la condivisione: $e',
        color: ColorPalette.error,
      );
    }
  }
}
