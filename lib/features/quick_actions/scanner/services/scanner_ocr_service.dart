import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerOcrService {
  ScannerOcrService({TextRecognizer? latinRecognizer})
      : _latin = latinRecognizer ??
            TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _latin;

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final latin = await _latin.processImage(inputImage);

    return latin.text.trim();
  }

  Future<String> extractFromPaths(List<String> paths) async {
    final buffer = StringBuffer();
    for (var i = 0; i < paths.length; i++) {
      final text = await extractText(paths[i]);
      if (text.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.writeln('\n--- Page ${i + 1} ---\n');
      buffer.writeln(text);
    }
    return buffer.toString().trim();
  }

  Future<void> dispose() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _latin.close().catchError((_) {});
    }
  }
}

final scannerOcrServiceProvider = Provider<ScannerOcrService>((ref) {
  final service = ScannerOcrService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
