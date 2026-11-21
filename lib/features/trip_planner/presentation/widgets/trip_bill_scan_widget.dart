import 'dart:io';

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

typedef TripBillOcrCallback = void Function(String ocrText);

class TripBillScanWidget extends ConsumerStatefulWidget {
  const TripBillScanWidget({
    super.key,
    required this.locale,
    required this.onOcrText,
    this.isProcessing = false,
  });

  final String locale;
  final TripBillOcrCallback onOcrText;
  final bool isProcessing;

  @override
  ConsumerState<TripBillScanWidget> createState() => _TripBillScanWidgetState();
}

class _TripBillScanWidgetState extends ConsumerState<TripBillScanWidget> {
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

  Future<void> _pick(ImageSource source) async {
    if (Platform.isMacOS && source == ImageSource.camera) {
      _snack(TripStrings.t('bill_scan_camera_mobile_only', widget.locale));
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
        _snack(TripStrings.t('bill_scan_unclear', widget.locale));
        return;
      }
      widget.onOcrText(text);
    } catch (_) {
      _snack(TripStrings.t('bill_scan_process_error', widget.locale));
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: GlassProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TripStrings.t('bill_scan_capture_hint', widget.locale),
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
                onPressed: () => _pick(ImageSource.camera),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GlassPrimaryButton(
                label: TripStrings.t('bill_scan_gallery', widget.locale),
                icon: Icons.photo_library_outlined,
                accentColor: AppColors.cyanGlow,
                onPressed: () => _pick(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
