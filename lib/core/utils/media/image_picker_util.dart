import 'dart:io';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Pick and optionally crop an image
  /// Returns the File if successful, null otherwise
  static Future<File?> pickImage({
    required BuildContext context,
    bool enableCropping = true,
    bool isCircular = false,
    double? aspectRatio,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      // If cropping is enabled, crop the image
      if (enableCropping && context.mounted) {
        final croppedFile = await _cropImage(
          context: context,
          imageFile: imageFile,
          isCircular: isCircular,
          aspectRatio: aspectRatio,
        );

        if (croppedFile == null) return null;
        imageFile = croppedFile;
      }

      return imageFile;
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          'Si è verificato un errore durante la selezione dell\'immagine',
        );
      }

      return null;
    }
  }

  /// Picks a video from the specified source
  /// Returns the File if successful, null otherwise
  static Future<File?> pickVideo({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          'Si è verificato un errore durante la selezione del video',
        );
      }

      return null;
    }
  }

  static Future<File?> _cropImage({
    required BuildContext context,
    required File imageFile,
    bool isCircular = false,
    double? aspectRatio,
  }) async {
    final theme = context.read<AppThemeCubit>().state.themeMode;
    final isDarkMode = theme == ThemeMode.dark;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: aspectRatio != null
          ? CropAspectRatio(ratioX: aspectRatio, ratioY: 1)
          : null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ritaglia immagine',
          toolbarColor: context.primaryColor,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: context.primaryColor,
          backgroundColor: isDarkMode ? ColorPalette.black : ColorPalette.white,
          statusBarColor: context.primaryColor,
          cropStyle: isCircular ? CropStyle.circle : CropStyle.rectangle,
        ),
        IOSUiSettings(
          title: 'Ritaglia immagine',
          doneButtonTitle: 'Fatto',
          cancelButtonTitle: 'Annulla',
          cropStyle: isCircular ? CropStyle.circle : CropStyle.rectangle,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }
}
