import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/features/quick_actions/scanner/models/scan_filter.dart';

class ScannerImageService {
  Future<Uint8List> readBytes(String path) =>
      File(path).readAsBytes();

  Future<Uint8List> applyFilter(String path, ScanFilter filter) async {
    if (filter == ScanFilter.original) {
      return readBytes(path);
    }

    final bytes = await readBytes(path);
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    img.Image output;
    switch (filter) {
      case ScanFilter.grayscale:
        output = img.grayscale(decoded);
      case ScanFilter.blackWhite:
        output = img.grayscale(decoded);
        output = img.adjustColor(output, contrast: 1.35, brightness: 0.05);
      case ScanFilter.colorEnhance:
        output = img.adjustColor(
          decoded,
          contrast: 1.15,
          saturation: 1.25,
          brightness: 0.03,
        );
      case ScanFilter.magicColor:
        output = img.adjustColor(
          decoded,
          contrast: 1.2,
          saturation: 1.35,
          gamma: 1.05,
        );
      case ScanFilter.highContrast:
        output = img.adjustColor(decoded, contrast: 1.55, brightness: 0.02);
      case ScanFilter.documentMode:
        output = img.grayscale(decoded);
        output = img.adjustColor(output, contrast: 1.4, brightness: 0.08);
      case ScanFilter.receiptMode:
        output = img.adjustColor(
          decoded,
          contrast: 1.25,
          brightness: 0.1,
          saturation: 0.85,
        );
      case ScanFilter.lowLight:
        output = img.adjustColor(
          decoded,
          brightness: 0.18,
          contrast: 1.1,
          gamma: 0.92,
        );
      case ScanFilter.original:
        output = decoded;
    }

    return Uint8List.fromList(img.encodeJpg(output, quality: 92));
  }

  Future<Uint8List> applyWatermark(
    Uint8List bytes, {
    bool enabled = true,
  }) async {
    if (!enabled) return bytes;

    final original = img.decodeImage(bytes);
    if (original == null) return bytes;

    final watermarkText =
        'Scanned by RAABTA  •  ${CommonStrings.publicWebsiteHost}';
    final yPos = original.height - 52;

    img.fillRect(
      original,
      x1: 0,
      y1: yPos - 10,
      x2: original.width,
      y2: yPos + 52,
      color: img.ColorRgba8(0, 0, 0, 170),
    );
    img.drawString(
      original,
      watermarkText,
      font: img.arial24,
      x: 20,
      y: yPos,
      color: img.ColorRgba8(255, 255, 255, 220),
    );
    return Uint8List.fromList(img.encodeJpg(original, quality: 92));
  }

  Future<String> saveProcessed(String sourcePath, Uint8List bytes) async {
    final file = File(sourcePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

final scannerImageServiceProvider =
    Provider((ref) => ScannerImageService());
