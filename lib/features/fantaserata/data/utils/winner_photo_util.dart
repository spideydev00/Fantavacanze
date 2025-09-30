import 'dart:io';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';

class WinnerPhotoUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Captures a photo using only the camera
  static Future<File?> captureWinnerPhoto(
    BuildContext context, {
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: preferredCameraDevice,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (context.mounted) {
        showSnackBar(
          'Errore durante lo scatto: $e',
          color: ColorPalette.error,
        );
      }
      return null;
    }
  }

  static Future<Uint8List> _ensureSelfieFormat(Uint8List bytes) async {
    // 3:4 verticale (es. 1080x1440)
    const int targetW = 1080;
    const int targetH = 1440;

    // Decodifica e sistema l’orientamento EXIF
    img.Image? src = img.decodeImage(bytes);
    if (src == null) throw Exception('Could not decode image');
    src = img.bakeOrientation(src);

    // Calcola scala "cover": riempi TUTTO il target e poi crop al centro
    final double scale = (targetW / src.width > targetH / src.height)
        ? targetW / src.width
        : targetH / src.height;

    final int scaledW = (src.width * scale).round();
    final int scaledH = (src.height * scale).round();

    final img.Image scaled = img.copyResize(
      src,
      width: scaledW,
      height: scaledH,
      interpolation: img.Interpolation.cubic,
    );

    // Crop centrale esatto al 3:4
    final int cropX = ((scaledW - targetW) / 2).round();
    final int cropY = ((scaledH - targetH) / 2).round();

    final img.Image out = img.copyCrop(
      scaled,
      x: cropX,
      y: cropY,
      width: targetW,
      height: targetH,
    );

    return Uint8List.fromList(img.encodeJpg(out, quality: 90));
  }

  static Future<Uint8List> brandWinnerPhoto(Uint8List normalizedBytes) async {
    const int W = 1080;
    const int H = 1440;

    // Base
    final img.Image base = img.decodeImage(normalizedBytes)!;

    // Logo PNG
    final ByteData logoData = await rootBundle.load(
      'assets/images/fantaserata/logo/winner-text.png',
    );

    final img.Image logo = img.decodePng(logoData.buffer.asUint8List())!;

    final int logoW = (W * 0.85).round();
    final int logoH = (logoW / (logo.width / logo.height)).round();
    final int logoX = ((W - logoW) / 2).round();
    const int marginBottom = 20;
    final int logoY = H - marginBottom - logoH;

    final img.Image logoScaled = img.copyResize(
      logo,
      width: logoW,
      height: logoH,
    );

    img.compositeImage(
      base,
      logoScaled,
      dstX: logoX,
      dstY: logoY,
    );

    return Uint8List.fromList(img.encodeJpg(base, quality: 90));
  }

  /// End-to-end method that handles the complete winner photo flow using BLoC
  static Future<void> captureBrandUploadAndShareWinner({
    required BuildContext context,
    required String leagueId,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        Loader(color: context.primaryColor);
      }

      // Step 1: Capture photo
      final File? capturedPhoto = await captureWinnerPhoto(
        context,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (capturedPhoto == null) {
        if (context.mounted) {
          showSnackBar(
            'Scatto annullato',
            color: ColorPalette.error,
          );
        }
        return;
      }

      // Step 2: Normalize to selfie format (3:4)
      final Uint8List originalBytes = await capturedPhoto.readAsBytes();
      final Uint8List normalized = await _ensureSelfieFormat(originalBytes);

      // Step 3: Add branding (logo + text)
      final Uint8List branded = await brandWinnerPhoto(normalized);

      // Step 4: Upload using BLoC
      if (context.mounted) {
        context.read<FsBloc>().add(UploadWinnerPhotoEvent(
              leagueId: leagueId,
              imageBytes: branded,
            ));
      }

      // Step 5: Save to temporary file for sharing
      final Directory tempDir = await getTemporaryDirectory();

      final String tempPath =
          '${tempDir.path}/winner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(branded);

      // Step 6: Share to Instagram Stories
      await shareWinnerStory(tempFile);

      // Clean up temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      debugPrint('Error in complete winner photo flow: $e');
      if (context.mounted) {
        showSnackBar(
          'Errore durante l\'elaborazione: $e',
          color: ColorPalette.error,
        );
      }
    }
  }

  /// Shares to Instagram Stories with fallback to general share
  static Future<void> shareToInstagramStories(File jpgFile) async {
    try {
      await _shareToInstagramStories(jpgFile);
    } catch (e) {
      debugPrint('Instagram Stories sharing failed, using fallback: $e');
    }
  }

  static Future<void> _shareToInstagramStories(File jpgFile) async {
    final XFile xFile = XFile(jpgFile.path);

    await SharePlus.instance.share(ShareParams(
      files: [xFile],
      text: 'Il vincitore del FantaSerata! 🏆',
      subject: 'FantaSerata Winner',
    ));
  }

  /// Main orchestrator method for the complete flow
  static Future<void> shareWinnerStory(File jpgFile) async {
    try {
      await shareToInstagramStories(jpgFile);
    } catch (e) {
      debugPrint('Error sharing winner story: $e');
    }
  }

  /// Method to share photo from URL (for existing photos)
  static Future<void> sharePhotoFromUrl(String photoUrl) async {
    try {
      // Download the image
      final response = await HttpClient().getUrl(Uri.parse(photoUrl));
      final httpResponse = await response.close();

      if (httpResponse.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(httpResponse);

        // Save to temporary file
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath =
            '${tempDir.path}/winner_share_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final File tempFile = File(tempPath);

        await tempFile.writeAsBytes(bytes);

        // Share the file
        await shareWinnerStory(tempFile);

        // Clean up temporary file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } else {
        throw Exception('Failed to download image: ${httpResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing photo from URL: $e');
      rethrow;
    }
  }
}
