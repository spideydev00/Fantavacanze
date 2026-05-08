import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<Uint8List> renderWidgetToPng(
    Widget widget, {
    required BuildContext context,
    double pixelRatio = 3.0,
  }) {
    return _screenshotController.captureFromWidget(
      widget,
      pixelRatio: pixelRatio,
      context: context,
      delay: const Duration(milliseconds: 100),
    );
  }

  Future<void> shareImageBytes(
    Uint8List bytes, {
    required Rect? originRect,
    String filename = 'Classifica Fantavacanze.png',
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png'),
        ],
        fileNameOverrides: [filename],
        sharePositionOrigin: originRect,
      ),
    );
  }
}
