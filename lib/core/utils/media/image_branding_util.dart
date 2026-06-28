import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:fantavacanze_official/core/utils/media/brand_logo_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageBrandingUtil {
  static final Map<String, Uint8List> _logoCache = {};

  static Future<Uint8List> _loadAsset(String path) async {
    final cached = _logoCache[path];
    if (cached != null) return cached;
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    _logoCache[path] = bytes;
    return bytes;
  }

  static Future<File> brandImageFromUrl(
    String imageUrl, {
    void Function(double progress)? onDownloadProgress,
    VoidCallback? onBrandingStart,
    CancelToken? cancelToken,
    ThemeMode themeMode = ThemeMode.dark,
    String? partnerSlug,
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

    final fvLogoBytes = await _loadAsset(BrandLogoAssets.fvLogo(themeMode));
    final partnerLogoBytes = partnerSlug == null
        ? null
        : await _loadAsset(BrandLogoAssets.partnerLogo(partnerSlug, themeMode));
    onBrandingStart?.call();

    final brandedBytes = await compute(
      _brandImageInIsolate,
      _BrandPayload(
        baseBytes: Uint8List.fromList(response.data!),
        fvLogoBytes: fvLogoBytes,
        partnerLogoBytes: partnerLogoBytes,
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
    ThemeMode themeMode = ThemeMode.dark,
    String? partnerSlug,
  }) async {
    final file = await brandImageFromUrl(
      imageUrl,
      onDownloadProgress: onDownloadProgress,
      onBrandingStart: onBrandingStart,
      cancelToken: cancelToken,
      themeMode: themeMode,
      partnerSlug: partnerSlug,
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
  final fvLogo = img.decodeImage(payload.fvLogoBytes);
  final partnerLogo = payload.partnerLogoBytes == null
      ? null
      : img.decodeImage(payload.partnerLogoBytes!);

  if (baseImage == null || fvLogo == null) {
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

  img.Image scaled(img.Image logo) {
    final width = math.max(1, (baseImage!.width * 0.18).round());
    final height = math.max(1, (logo.height * width / logo.width).round());
    return img.copyResize(
      logo,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );
  }

  final scaledFv = scaled(fvLogo);
  final scaledPartner = partnerLogo == null ? null : scaled(partnerLogo);

  final gap = (baseImage.width * 0.04).round();
  final totalWidth =
      scaledFv.width + (scaledPartner == null ? 0 : gap + scaledPartner.width);
  final maxHeight = math.max(scaledFv.height, scaledPartner?.height ?? 0);
  final startX = ((baseImage.width - totalWidth) / 2).round();
  final baseY =
      baseImage.height - maxHeight - (baseImage.height * 0.03).round();

  img.compositeImage(
    baseImage,
    scaledFv,
    dstX: startX,
    dstY: baseY + ((maxHeight - scaledFv.height) / 2).round(),
  );

  if (scaledPartner != null) {
    img.compositeImage(
      baseImage,
      scaledPartner,
      dstX: startX + scaledFv.width + gap,
      dstY: baseY + ((maxHeight - scaledPartner.height) / 2).round(),
    );
  }

  return img.encodeJpg(baseImage, quality: 85);
}

class _BrandPayload {
  final Uint8List baseBytes;
  final Uint8List fvLogoBytes;
  final Uint8List? partnerLogoBytes;

  const _BrandPayload({
    required this.baseBytes,
    required this.fvLogoBytes,
    this.partnerLogoBytes,
  });
}
