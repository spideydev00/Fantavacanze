import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageBrandingUtil {
  static const String _logoAssetPath = 'assets/images/logos/logo-neon.png';

  static Uint8List? _cachedLogoBytes;

  static Future<Uint8List> _loadLogoBytes() async {
    final cachedLogoBytes = _cachedLogoBytes;
    if (cachedLogoBytes != null) return cachedLogoBytes;

    final logoData = await rootBundle.load(_logoAssetPath);
    final logoBytes = logoData.buffer.asUint8List(
      logoData.offsetInBytes,
      logoData.lengthInBytes,
    );

    _cachedLogoBytes = logoBytes;
    return logoBytes;
  }

  static Future<File> brandImageFromUrl(
    String imageUrl, {
    void Function(double progress)? onDownloadProgress,
    VoidCallback? onBrandingStart,
    CancelToken? cancelToken,
  }) async {
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0 && onDownloadProgress != null) {
          onDownloadProgress(received / total);
        }
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Errore elaborazione immagine');
    }

    final logoBytes = await _loadLogoBytes();
    onBrandingStart?.call();

    final brandedBytes = await compute(
      _brandImageInIsolate,
      _BrandPayload(
        baseBytes: Uint8List.fromList(response.data!),
        logoBytes: logoBytes,
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/memory_share_$timestamp.jpg');

    await file.writeAsBytes(brandedBytes, flush: true);
    return file;
  }

  static Future<bool> saveBrandedImageToGallery(
    String imageUrl, {
    void Function(double progress)? onDownloadProgress,
    VoidCallback? onBrandingStart,
    VoidCallback? onSavingStart,
    CancelToken? cancelToken,
  }) async {
    final file = await brandImageFromUrl(
      imageUrl,
      onDownloadProgress: onDownloadProgress,
      onBrandingStart: onBrandingStart,
      cancelToken: cancelToken,
    );

    try {
      if (cancelToken?.isCancelled == true) return false;

      onSavingStart?.call();
      final saved = await GallerySaver.saveImage(file.path);
      return saved ?? false;
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }

  static Future<void> shareFiles(List<File> files, {String? text}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: files.map((file) => XFile(file.path)).toList(),
          text: text,
        ),
      );
    } finally {
      for (final file in files) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }
  }
}

Uint8List _brandImageInIsolate(_BrandPayload payload) {
  var baseImage = img.decodeImage(payload.baseBytes);
  final logoImage = img.decodeImage(payload.logoBytes);

  if (baseImage == null || logoImage == null) {
    throw Exception('Errore elaborazione immagine');
  }

  baseImage = img.bakeOrientation(baseImage);

  final longestSide = math.max(baseImage.width, baseImage.height);
  if (longestSide > 2048) {
    baseImage = baseImage.width >= baseImage.height
        ? img.copyResize(
            baseImage,
            width: 2048,
            interpolation: img.Interpolation.cubic,
          )
        : img.copyResize(
            baseImage,
            height: 2048,
            interpolation: img.Interpolation.cubic,
          );
  }

  final logoWidth = math.max(1, (baseImage.width * 0.22).round());
  final logoHeight = math.max(
    1,
    (logoImage.height * logoWidth / logoImage.width).round(),
  );
  final scaledLogo = img.copyResize(
    logoImage,
    width: logoWidth,
    height: logoHeight,
    interpolation: img.Interpolation.cubic,
  );

  img.compositeImage(
    baseImage,
    scaledLogo,
    dstX: ((baseImage.width - scaledLogo.width) / 2).round(),
    dstY: baseImage.height -
        scaledLogo.height -
        (baseImage.height * 0.03).round(),
  );

  return img.encodeJpg(baseImage, quality: 85);
}

class _BrandPayload {
  final Uint8List baseBytes;
  final Uint8List logoBytes;

  const _BrandPayload({
    required this.baseBytes,
    required this.logoBytes,
  });
}
