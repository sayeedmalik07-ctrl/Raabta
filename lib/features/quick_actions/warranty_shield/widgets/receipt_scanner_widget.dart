import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import '../../../../services/ai/document_extraction_service.dart';
import 'package:raabta/core/colors/app_colors.dart';

// ─── Result passed back to the warranty form ─────────────

class ScannedReceiptData {
  final String? productName;
  final String? brand;
  final DateTime? purchaseDate;
  final double? price;
  final int? warrantyPeriodGuessMonths;
  final double confidence;

  const ScannedReceiptData({
    this.productName,
    this.brand,
    this.purchaseDate,
    this.price,
    this.warrantyPeriodGuessMonths,
    required this.confidence,
  });

  bool get isHighConfidence => confidence >= 0.65;
  bool get isMediumConfidence =>
      confidence >= 0.4 && confidence < 0.65;
  bool get isLowConfidence => confidence < 0.4;

  Color get confidenceColor {
    if (isHighConfidence) return AppColors.successBright;
    if (isMediumConfidence) return AppColors.accentGold;
    return AppColors.errorBright;
  }

  String confidenceLabel(String locale) =>
      WarrantyStrings.scanConfidenceLabel(confidence, locale);
}

// ─── WIDGET ──────────────────────────────────────────────

class ReceiptScannerWidget extends ConsumerStatefulWidget {
  // Called when extraction completes — passes data to parent
  final Function(ScannedReceiptData data) onDataExtracted;

  const ReceiptScannerWidget({
    super.key,
    required this.onDataExtracted,
  });

  @override
  ConsumerState<ReceiptScannerWidget> createState() =>
      _ReceiptScannerWidgetState();
}

class _ReceiptScannerWidgetState
    extends ConsumerState<ReceiptScannerWidget> {

  final _imagePicker   = ImagePicker();
  final _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _textRecognizer.close().catchError((_) {});
    }
    super.dispose();
  }

  // ── Capture from camera ──────────────────────────────
  Future<void> _scanWithCamera() async {
    if (Platform.isMacOS) {
      final locale = ref.read(userLanguageProvider);
      _showSnack(WarrantyStrings.t('warr_scan_camera_macos', locale));
      return;
    }
    await _pickAndProcess(ImageSource.camera);
  }

  // ── Upload from gallery ──────────────────────────────
  Future<void> _uploadFromGallery() async {
    await _pickAndProcess(ImageSource.gallery);
  }

  // ── Core flow: pick → OCR → extraction service ───────
  Future<void> _pickAndProcess(ImageSource source) async {
    final locale = ref.read(userLanguageProvider);
    try {
      final picked = await _imagePicker.pickImage(
        source:       source,
        imageQuality: 90,
      );
      if (picked == null) return;

      setState(() {
        _isProcessing = true;
        _statusMessage = WarrantyStrings.t('warr_scan_reading', locale);
      });

      // ── OCR step ─────────────────────────────────────
      final inputImage = InputImage.fromFilePath(picked.path);
      final recognized =
          await _textRecognizer.processImage(inputImage);
      final ocrText = recognized.text;

      if (ocrText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        _showSnack(WarrantyStrings.t('warr_scan_no_text', locale));
        return;
      }

      setState(() {
        _statusMessage = WarrantyStrings.t('warr_scan_extracting', locale);
      });

      // ✅ Uses EXISTING DocumentExtractionService
      // Do NOT create a new Claude call here
      final extractionService =
          ref.read(documentExtractionServiceProvider);
      final result =
          await extractionService.extractReceiptData(ocrText);

      // Map to ScannedReceiptData
      final scannedData = ScannedReceiptData(
        productName:  result.productName,
        brand:        result.store, // store name as brand hint
        purchaseDate: result.purchaseDate,
        price:        result.price,
        warrantyPeriodGuessMonths:
            result.warrantyPeriodGuessMonths,
        confidence:   result.confidence,
      );

      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });

      // Pass extracted data to parent
      widget.onDataExtracted(scannedData);

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
      _showSnack(WarrantyStrings.t('warr_scan_process_error', locale));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1035),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    if (_isProcessing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sharePurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.sharePurple.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.sharePurple,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage ?? WarrantyStrings.t('warr_scan_processing', locale),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sharePurple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sharePurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.sharePurple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                WarrantyStrings.t('warr_scan_title', locale),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                WarrantyStrings.t('warr_scan_ai_powered', locale),
                style: TextStyle(
                  color: AppColors.sharePurple
                      .withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scanWithCamera,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    WarrantyStrings.scanCamera(locale),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sharePurple,
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploadFromGallery,
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.accentGold,
                    size: 16,
                  ),
                  label: Text(
                    WarrantyStrings.scanGallery(locale),
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                    side: BorderSide(
                      color: AppColors.accentGold
                          .withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            WarrantyStrings.t('warr_scan_subtitle', locale),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
