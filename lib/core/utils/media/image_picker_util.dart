import 'dart:io';

import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/media/media_size_guard.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/processing_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

enum MediaPreset {
  avatar(
    maxLongSide: 640,
    jpegQuality: 88,
    sizeType: MediaSizeType.avatar,
  ),
  memory(
    maxLongSide: 2048,
    jpegQuality: 88,
    sizeType: MediaSizeType.memoryPhoto,
  );

  const MediaPreset({
    required this.maxLongSide,
    required this.jpegQuality,
    required this.sizeType,
  });

  final int maxLongSide;
  final int jpegQuality;
  final MediaSizeType sizeType;
}

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required BuildContext context,
    required MediaPreset preset,
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

      final shouldFlipFrontCamera = source == ImageSource.camera;
      if (shouldFlipFrontCamera && context.mounted) {
        imageFile = await _processImageWithDialog(
          context,
          imageFile,
          preset,
          shouldFlipFrontCamera: true,
        );
      } else {
        imageFile = await _processPickedImage(
          imageFile,
          preset,
          shouldFlipFrontCamera: shouldFlipFrontCamera,
        );
      }

      if (enableCropping && context.mounted) {
        final croppedFile = await _cropImage(
          context: context,
          imageFile: imageFile,
          isCircular: isCircular,
          aspectRatio: aspectRatio,
          jpegQuality: preset.jpegQuality,
        );

        if (croppedFile == null) return null;
        imageFile = croppedFile;
      }

      final isValidSize = await guardMediaSize(
        file: imageFile,
        type: preset.sizeType,
        onTooLarge: showSnackBar,
      );
      if (!isValidSize) return null;

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

      final compressed = await VideoCompress.compressVideo(
        pickedFile.path,
        quality: VideoQuality.Res1280x720Quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      final compressedPath = compressed?.path;
      if (compressedPath == null) {
        showSnackBar(
          'Si è verificato un errore durante la compressione del video',
        );
        return null;
      }

      final videoFile = File(compressedPath);
      final isValidSize = await guardMediaSize(
        file: videoFile,
        type: MediaSizeType.memoryVideo,
        onTooLarge: showSnackBar,
      );
      if (!isValidSize) return null;

      return videoFile;
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
    required int jpegQuality,
  }) async {
    final theme = context.read<AppThemeCubit>().state.themeMode;
    final isDarkMode = theme == ThemeMode.dark;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: aspectRatio != null
          ? CropAspectRatio(ratioX: aspectRatio, ratioY: 1)
          : null,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: jpegQuality,
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

  static Future<File> _processImageWithDialog(
    BuildContext context,
    File sourceFile,
    MediaPreset preset, {
    required bool shouldFlipFrontCamera,
  }) async {
    if (!context.mounted) {
      return _processPickedImage(
        sourceFile,
        preset,
        shouldFlipFrontCamera: shouldFlipFrontCamera,
      );
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
      return await _processPickedImage(
        sourceFile,
        preset,
        shouldFlipFrontCamera: shouldFlipFrontCamera,
      );
    } finally {
      final navigator = dialogNavigator;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
      notifier.dispose();
    }
  }

  static Future<File> _processPickedImage(
    File sourceFile,
    MediaPreset preset, {
    required bool shouldFlipFrontCamera,
  }) async {
    try {
      final bytes = await sourceFile.readAsBytes();

      final processed = await _resizeAndCompress(
        bytes,
        preset,
        shouldFlipFrontCamera: shouldFlipFrontCamera,
      );
      if (processed == null) return sourceFile;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outFile = File('${tempDir.path}/picked_$timestamp.jpg');
      await outFile.writeAsBytes(processed, flush: true);
      return outFile;
    } catch (e) {
      debugPrint('Image processing failed: $e');
      return sourceFile;
    }
  }

  static Future<Uint8List?> _resizeAndCompress(
    Uint8List bytes,
    MediaPreset preset, {
    required bool shouldFlipFrontCamera,
  }) {
    return compute(
      _resizeAndCompressInIsolate,
      (
        bytes: bytes,
        maxLongSide: preset.maxLongSide,
        jpegQuality: preset.jpegQuality,
        shouldFlipFrontCamera: shouldFlipFrontCamera,
      ),
    );
  }
}

typedef _ResizeAndCompressInput = ({
  Uint8List bytes,
  int maxLongSide,
  int jpegQuality,
  bool shouldFlipFrontCamera,
});

Uint8List? _resizeAndCompressInIsolate(_ResizeAndCompressInput input) {
  final bytes = input.bytes;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // Detect LensModel before transforms; bake orientation before front-camera mirror.
  final lensModelTag = decoded.exif.exifIfd[0xA434];
  final lensModel = lensModelTag?.toString().toLowerCase() ?? '';
  final isFrontCamera =
      input.shouldFlipFrontCamera && lensModel.contains('front');

  var processed = img.bakeOrientation(decoded);

  if (isFrontCamera) {
    processed = img.flipHorizontal(processed);
  }

  final longSide =
      processed.width > processed.height ? processed.width : processed.height;
  if (longSide > input.maxLongSide) {
    processed = processed.width >= processed.height
        ? img.copyResize(processed, width: input.maxLongSide)
        : img.copyResize(processed, height: input.maxLongSide);
  }

  return Uint8List.fromList(
    img.encodeJpg(processed, quality: input.jpegQuality),
  );
}
