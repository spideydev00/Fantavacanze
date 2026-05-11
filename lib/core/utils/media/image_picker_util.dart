import 'dart:io';

import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/processing_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

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
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front,
        requestFullMetadata: true,
      );

      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      if (source == ImageSource.camera) {
        // Bake EXIF orientation and mirror front-camera shots to match the preview the user saw on iOS. Blocca la UI durante l'attesa.
        imageFile = context.mounted
            ? await _normalizeWithDialog(context, imageFile)
            : await _normalizeAndMaybeFlipFromCamera(imageFile);
      }

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
          statusBarLight: true,
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

  static Future<File> _normalizeWithDialog(
    BuildContext context,
    File sourceFile,
  ) async {
    if (!context.mounted) {
      return _normalizeAndMaybeFlipFromCamera(sourceFile);
    }

    final notifier = ValueNotifier<ProcessingState>(
      const ProcessingState('Elaborazione immagine in corso...'),
    );

    NavigatorState? dialogNavigator;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogNavigator = Navigator.of(ctx);
        return ProcessingDialog(
          state: notifier,
          leadingIcon: Icons.auto_fix_high_rounded,
          onCancel: null,
        );
      },
    );

    try {
      return await _normalizeAndMaybeFlipFromCamera(sourceFile);
    } finally {
      final navigator = dialogNavigator;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
      notifier.dispose();
    }
  }

  static Future<File> _normalizeAndMaybeFlipFromCamera(File sourceFile) async {
    try {
      final bytes = await sourceFile.readAsBytes();

      final normalized = await compute(_normalizeImageInIsolate, bytes);
      if (normalized == null) return sourceFile;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outFile = File('${tempDir.path}/picked_$timestamp.jpg');
      await outFile.writeAsBytes(normalized, flush: true);
      return outFile;
    } catch (e) {
      debugPrint('Image normalization failed: $e');
      return sourceFile;
    }
  }
}

Uint8List? _normalizeImageInIsolate(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // Detect LensModel before transforms; bake orientation before front-camera mirror.
  final lensModelTag = decoded.exif.exifIfd[0xA434];
  final lensModel = lensModelTag?.toString().toLowerCase() ?? '';
  final isFrontCamera = lensModel.contains('front');

  var processed = img.bakeOrientation(decoded);

  if (isFrontCamera) {
    processed = img.flipHorizontal(processed);
  }

  return Uint8List.fromList(img.encodeJpg(processed, quality: 85));
}
