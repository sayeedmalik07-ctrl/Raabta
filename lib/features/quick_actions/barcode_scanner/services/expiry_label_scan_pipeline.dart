import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';

/// Capture product label photo → OCR text (separate from barcode lookup).
class ExpiryLabelScanPipeline {
  ExpiryLabelScanPipeline(this._ocr);

  final ScannerOcrService _ocr;
  final ImagePicker _picker = ImagePicker();

  bool get supportsDocumentCamera =>
      !isScannerDesktop && (Platform.isIOS || Platform.isAndroid);

  Future<String?> pickGalleryAndOcr() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;
    return _ocr.extractText(picked.path);
  }

  Future<String?> captureAndOcr() async {
    if (!supportsDocumentCamera) return null;
    final pictures = await CunningDocumentScanner.getPictures(
      noOfPages: 1,
      isGalleryImportAllowed: true,
    );
    if (pictures == null || pictures.isEmpty) return null;
    return _ocr.extractText(pictures.first);
  }
}

final expiryLabelScanPipelineProvider = Provider<ExpiryLabelScanPipeline>((ref) {
  return ExpiryLabelScanPipeline(ref.watch(scannerOcrServiceProvider));
});
