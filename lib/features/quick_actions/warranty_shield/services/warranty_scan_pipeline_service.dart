import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class WarrantyScanPipelineResult {
  const WarrantyScanPipelineResult({
    required this.extraction,
    required this.ocrText,
    this.imagePaths = const [],
  });

  final WarrantyExtractionResult extraction;
  final String ocrText;
  final List<String> imagePaths;
}

/// Capture → OCR → warranty extraction (same capture stack as Bill Tracker).
class WarrantyScanPipelineService {
  WarrantyScanPipelineService(this._ocr, this._extraction);

  final ScannerOcrService _ocr;
  final DocumentExtractionService _extraction;
  final ImagePicker _picker = ImagePicker();

  bool get supportsDocumentCamera =>
      !isScannerDesktop && (Platform.isIOS || Platform.isAndroid);

  Future<List<String>?> pickGalleryPaths() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;
    return [picked.path];
  }

  Future<List<String>?> captureWithDocumentScanner() async {
    if (!supportsDocumentCamera) return null;

    final pictures = await CunningDocumentScanner.getPictures(
      noOfPages: 1,
      isGalleryImportAllowed: false,
    );
    if (pictures == null || pictures.isEmpty) return null;
    return pictures;
  }

  Future<WarrantyScanPipelineResult?> runFromPaths(List<String> paths) async {
    if (paths.isEmpty) return null;

    final ocrText = await _ocr.extractFromPaths(paths);
    if (ocrText.trim().isEmpty) return null;

    final extraction = await _extraction.extractWarrantyData(ocrText);
    return WarrantyScanPipelineResult(
      extraction: extraction,
      ocrText: ocrText,
      imagePaths: paths,
    );
  }

  Future<WarrantyScanPipelineResult?> runFromCapture(
    BillScanCaptureSource source,
  ) async {
    final paths = switch (source) {
      BillScanCaptureSource.gallery => await pickGalleryPaths(),
      BillScanCaptureSource.camera => await captureWithDocumentScanner(),
      BillScanCaptureSource.pdf => null,
    };
    if (paths == null || paths.isEmpty) return null;
    return runFromPaths(paths);
  }
}

final warrantyScanPipelineServiceProvider =
    Provider<WarrantyScanPipelineService>((ref) {
  return WarrantyScanPipelineService(
    ref.watch(scannerOcrServiceProvider),
    ref.watch(documentExtractionServiceProvider),
  );
});
