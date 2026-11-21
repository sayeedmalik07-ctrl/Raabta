import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/scanner/models/scan_filter.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_image_service.dart';

enum PdfPageFormatOption { a4, a5, letter, legal }

enum PdfCompressionLevel { low, medium, high, maximum }

class PdfBuildOptions {
  const PdfBuildOptions({
    this.format = PdfPageFormatOption.a4,
    this.landscape = false,
    this.includePageNumbers = false,
    this.watermark = false,
    this.compression = PdfCompressionLevel.medium,
  });

  final PdfPageFormatOption format;
  final bool landscape;
  final bool includePageNumbers;
  final bool watermark;
  final PdfCompressionLevel compression;
}

class PdfCompressionResult {
  const PdfCompressionResult({
    required this.originalBytes,
    required this.compressedBytes,
  });

  final int originalBytes;
  final int compressedBytes;

  double get ratio =>
      originalBytes == 0 ? 0 : compressedBytes / originalBytes;

  int get savedPercent =>
      originalBytes == 0 ? 0 : ((1 - ratio) * 100).round();
}

class ScannerPdfService {
  ScannerPdfService(this._images);

  final ScannerImageService _images;

  PdfPageFormat _pageFormat(PdfBuildOptions options) {
    final base = switch (options.format) {
      PdfPageFormatOption.a4 => PdfPageFormat.a4,
      PdfPageFormatOption.a5 => PdfPageFormat.a5,
      PdfPageFormatOption.letter => PdfPageFormat.letter,
      PdfPageFormatOption.legal => PdfPageFormat.legal,
    };
    return options.landscape ? base.landscape : base;
  }

  int _jpegQuality(PdfCompressionLevel level) {
    switch (level) {
      case PdfCompressionLevel.low:
        return 88;
      case PdfCompressionLevel.medium:
        return 75;
      case PdfCompressionLevel.high:
        return 62;
      case PdfCompressionLevel.maximum:
        return 48;
    }
  }

  Future<Uint8List> buildFromImages({
    required List<String> imagePaths,
    ScanFilter filter = ScanFilter.original,
    PdfBuildOptions options = const PdfBuildOptions(),
    bool applyWatermark = true,
  }) async {
    final doc = pw.Document();
    final quality = _jpegQuality(options.compression);
    final pageFormat = _pageFormat(options);

    for (var i = 0; i < imagePaths.length; i++) {
      var bytes = await _images.applyFilter(imagePaths[i], filter);
      bytes = await _images.applyWatermark(
        bytes,
        enabled: applyWatermark || options.watermark,
      );
      // Re-encode with compression quality when filter applied
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
      }

      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (ctx) => pw.Stack(
            children: [
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(bytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
              if (options.includePageNumbers)
                pw.Align(
                  alignment: pw.Alignment.bottomCenter,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Text(
                      'Page ${i + 1} of ${imagePaths.length}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  Future<List<Uint8List>> splitImagesToPdfs({
    required List<String> imagePaths,
    ScanFilter filter = ScanFilter.original,
    PdfBuildOptions options = const PdfBuildOptions(),
    bool applyWatermark = true,
  }) async {
    final pdfs = <Uint8List>[];
    for (final path in imagePaths) {
      pdfs.add(
        await buildFromImages(
          imagePaths: [path],
          filter: filter,
          options: options,
          applyWatermark: applyWatermark,
        ),
      );
    }
    return pdfs;
  }

  Future<Uint8List> compressImagesToPdf({
    required List<String> imagePaths,
    ScanFilter filter = ScanFilter.original,
    PdfBuildOptions options = const PdfBuildOptions(),
    bool applyWatermark = true,
  }) {
    return buildFromImages(
      imagePaths: imagePaths,
      filter: filter,
      options: options,
      applyWatermark: applyWatermark,
    );
  }

  Future<PdfCompressionResult> compareCompression({
    required List<String> imagePaths,
    ScanFilter filter = ScanFilter.original,
    bool applyWatermark = true,
  }) async {
    final original = await buildFromImages(
      imagePaths: imagePaths,
      filter: filter,
      options: const PdfBuildOptions(compression: PdfCompressionLevel.low),
      applyWatermark: applyWatermark,
    );
    final compressed = await buildFromImages(
      imagePaths: imagePaths,
      filter: filter,
      options: const PdfBuildOptions(compression: PdfCompressionLevel.maximum),
      applyWatermark: applyWatermark,
    );
    return PdfCompressionResult(
      originalBytes: original.length,
      compressedBytes: compressed.length,
    );
  }

  Future<File> writeTempPdf(Uint8List bytes, {String prefix = 'RAABTA'}) async {
    final dir = Directory.systemTemp;
    final file = File(
      '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

final scannerPdfServiceProvider = Provider((ref) {
  return ScannerPdfService(ref.read(scannerImageServiceProvider));
});
