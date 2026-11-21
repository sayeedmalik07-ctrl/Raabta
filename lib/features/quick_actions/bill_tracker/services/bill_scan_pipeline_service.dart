import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/scanned_bill_data.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';
import 'package:raabta/services/documents/utils/pdf_text_utils.dart';

enum BillScanCaptureSource { camera, gallery, pdf }

class BillScanPipelineResult {
  const BillScanPipelineResult({
    required this.data,
    required this.extraction,
    required this.ocrText,
    this.imagePaths = const [],
    this.pdfPath,
  });

  final ScannedBillData data;
  final BillExtractionResult extraction;
  final String ocrText;
  final List<String> imagePaths;
  final String? pdfPath;
}

/// RAABTA bill scan pipeline: capture/import → OCR/text → bill extraction.
class BillScanPipelineService {
  BillScanPipelineService(this._ocr, this._extraction);

  final ScannerOcrService _ocr;
  final DocumentExtractionService _extraction;
  final ImagePicker _picker = ImagePicker();

  bool get supportsDocumentCamera =>
      !isScannerDesktop && (Platform.isIOS || Platform.isAndroid);

  Future<List<String>?> pickGalleryPaths({bool allowMultiple = false}) async {
    if (allowMultiple) {
      final picked = await _picker.pickMultiImage(imageQuality: 90);
      if (picked.isEmpty) return null;
      return picked.map((file) => file.path).toList(growable: false);
    }

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

  Future<BillScanPipelineResult?> runFromOcrText(
    String ocrText, {
    String? sourceImagePath,
    String? pdfPath,
    List<String> imagePaths = const [],
  }) async {
    if (ocrText.trim().isEmpty) return null;

    final extraction = await _extraction.extractBillData(ocrText);
    return BillScanPipelineResult(
      data: ScannedBillData.fromExtraction(
        extraction,
        ocrText: ocrText,
        sourceImagePath: sourceImagePath,
        sourcePdfPath: pdfPath,
      ),
      extraction: extraction,
      ocrText: ocrText,
      imagePaths: imagePaths.isNotEmpty
          ? imagePaths
          : (sourceImagePath != null ? [sourceImagePath] : const []),
      pdfPath: pdfPath,
    );
  }

  Future<BillScanPipelineResult?> runFromPaths(List<String> paths) async {
    if (paths.isEmpty) return null;

    final ocrText = await _ocr.extractFromPaths(paths);
    if (ocrText.trim().isEmpty) return null;

    return runFromOcrText(
      ocrText,
      sourceImagePath: paths.first,
      imagePaths: paths,
    );
  }

  Future<BillScanPipelineResult?> runFromPdfPath(String path) async {
    final bytes = await File(path).readAsBytes();
    final text = PdfTextUtils.extractText(bytes);
    if (text.trim().length < 20) return null;

    return runFromOcrText(
      text.trim(),
      pdfPath: path,
    );
  }

  Future<BillScanPipelineResult?> runFromCapture(
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

final billScanPipelineServiceProvider = Provider<BillScanPipelineService>((ref) {
  return BillScanPipelineService(
    ref.watch(scannerOcrServiceProvider),
    ref.watch(documentExtractionServiceProvider),
  );
});
