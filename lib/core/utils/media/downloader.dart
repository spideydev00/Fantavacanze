import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class Downloader {
  final Dio _dio = Dio();

  /// Download file with progress tracking and save to gallery
  Future<String?> downloadFile(
    String url,
    String fileName, {
    Function(double)? onProgress,
    VoidCallback? onComplete,
    Function(String)? onError,
    required bool isVideo,
  }) async {
    try {
      // Get temporary directory for downloading
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final baseFileName = fileName.split('.').first;
      final tempFileName = '${baseFileName}_$timestamp.$extension';
      final tempFilePath = "${tempDir.path}/$tempFileName";

      // Download file to temporary location first
      await _dio.download(
        url,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
            debugPrint(
                "Download Progress: ${(progress * 100).toStringAsFixed(0)}%");
          }
        },
      );

      debugPrint("File scaricato su temp: $tempFilePath");

      // Now save to gallery using gallery_saver_plus
      bool? saveSuccess;
      if (isVideo) {
        saveSuccess = await GallerySaver.saveVideo(tempFilePath);
      } else {
        saveSuccess = await GallerySaver.saveImage(tempFilePath);
      }

      // Clean up temporary file
      try {
        final tempFile = File(tempFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        debugPrint("Errore nel cleanup del file temp: $e");
      }

      if (saveSuccess == true) {
        debugPrint("File salvato correttamente in galleria");
        onComplete?.call();
        return tempFilePath; // Return the path for reference
      } else {
        onError?.call("Errore nel salvare il file nella galleria");
        return null;
      }
    } catch (e) {
      debugPrint("Download fallito: $e");
      onError?.call("Errore durante il download: $e");
      return null;
    }
  }

  /// Download image file and save to gallery
  Future<String?> downloadImage(
    String imageUrl, {
    Function(double)? onProgress,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    final fileName =
        'fantavacanze_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return downloadFile(
      imageUrl,
      fileName,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
      isVideo: false,
    );
  }

  /// Download video file and save to gallery
  Future<String?> downloadVideo(
    String videoUrl, {
    Function(double)? onProgress,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    final fileName =
        'fantavacanze_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return downloadFile(
      videoUrl,
      fileName,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
      isVideo: true,
    );
  }

  /// Alternative method: Save directly from URL to gallery (faster for smaller files)
  Future<bool> saveImageFromUrl(String imageUrl) async {
    try {
      final bool? success = await GallerySaver.saveImage(imageUrl);
      return success ?? false;
    } catch (e) {
      debugPrint("Salvataggio diretto fallito: $e");
      return false;
    }
  }

  /// Alternative method: Save video directly from URL to gallery
  Future<bool> saveVideoFromUrl(String videoUrl) async {
    try {
      final bool? success = await GallerySaver.saveVideo(videoUrl);
      return success ?? false;
    } catch (e) {
      debugPrint("Salvataggio diretto fallito: $e");
      return false;
    }
  }

  /// Cancel ongoing downloads
  void cancelDownloads() {
    _dio.close();
  }
}
