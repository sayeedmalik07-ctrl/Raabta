import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/services/documents/utils/pdf_text_utils.dart';

typedef TripBookingOcrCallback = void Function(
  String ocrText, {
  required String sourcePath,
  String? pdfPath,
});

class TripBookingImportWidget extends ConsumerStatefulWidget {
  const TripBookingImportWidget({
    super.key,
    required this.locale,
    required this.onOcrText,
    this.isProcessing = false,
  });

  final String locale;
  final TripBookingOcrCallback onOcrText;
  final bool isProcessing;

  @override
  ConsumerState<TripBookingImportWidget> createState() =>
      _TripBookingImportWidgetState();
}

class _TripBookingImportWidgetState extends ConsumerState<TripBookingImportWidget> {
  final _imagePicker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _localProcessing = false;

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _textRecognizer.close().catchError((_) {});
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (Platform.isMacOS && source == ImageSource.camera) {
      _snack(TripStrings.t('booking_import_camera_mobile_only', widget.locale));
      return;
    }

    final picked = await _imagePicker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() => _localProcessing = true);
    try {
      final inputImage = InputImage.fromFilePath(picked.path);
      final recognized = await _textRecognizer.processImage(inputImage);
      final text = recognized.text.trim();
      if (text.isEmpty) {
        _snack(TripStrings.t('booking_import_unclear', widget.locale));
        return;
      }
      widget.onOcrText(text, sourcePath: picked.path);
    } catch (_) {
      _snack(TripStrings.t('booking_import_process_error', widget.locale));
    } finally {
      if (mounted) setState(() => _localProcessing = false);
    }
  }

  Future<void> _pickPdf() async {
    setState(() => _localProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final path = result?.files.single.path;
      if (path == null) return;

      final bytes = await File(path).readAsBytes();
      final text = PdfTextUtils.extractText(bytes);
      if (text.trim().length < 20) {
        _snack(TripStrings.t('booking_import_pdf_no_text', widget.locale));
        return;
      }
      widget.onOcrText(text.trim(), sourcePath: path, pdfPath: path);
    } catch (_) {
      _snack(TripStrings.t('booking_import_process_error', widget.locale));
    } finally {
      if (mounted) setState(() => _localProcessing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isProcessing || _localProcessing;

    if (busy) {
      return Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: GlassProgressIndicator(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TripStrings.t('booking_import_extracting', widget.locale),
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TripStrings.t('booking_import_capture_hint', widget.locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassPrimaryButton(
                label: TripStrings.t('bill_scan_camera', widget.locale),
                icon: Icons.camera_alt_outlined,
                accentColor: AppColors.chipTrip,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassPrimaryButton(
                label: TripStrings.t('bill_scan_gallery', widget.locale),
                icon: Icons.photo_library_outlined,
                accentColor: AppColors.cyanGlow,
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: TripStrings.t('booking_import_pdf', widget.locale),
          icon: Icons.picture_as_pdf_outlined,
          accentColor: AppColors.errorBright,
          expand: true,
          onPressed: _pickPdf,
        ),
      ],
    );
  }
}
