import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_text_import_section.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

class BillScanWidget extends ConsumerStatefulWidget {
  const BillScanWidget({
    super.key,
    required this.locale,
    this.onPipelineComplete,
    this.navigateToReview = true,
  });

  final String locale;
  final void Function(BillScanPipelineResult result)? onPipelineComplete;
  final bool navigateToReview;

  @override
  ConsumerState<BillScanWidget> createState() => _BillScanWidgetState();
}

class _BillScanWidgetState extends ConsumerState<BillScanWidget> {
  bool _isProcessing = false;
  String? _statusMessage;

  String get _s => widget.locale;

  Future<void> _finishPipeline(BillScanPipelineResult? result) async {
    if (!mounted) return;
    if (result == null || result.ocrText.trim().isEmpty) {
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
      if (result != null && result.ocrText.trim().isEmpty) {
        _showSnack(BillTrackerStrings.t('scan_no_text', _s));
      }
      return;
    }

    setState(() {
      _isProcessing = false;
      _statusMessage = null;
    });

    widget.onPipelineComplete?.call(result);
    if (widget.navigateToReview && mounted) {
      await context.push('/bill-tracker/scan/review', extra: result);
    }
  }

  Future<void> _runPipeline(BillScanCaptureSource source) async {
    if (source == BillScanCaptureSource.camera && isScannerDesktop) {
      _showSnack(BillTrackerStrings.t('scan_camera_macos', _s));
      return;
    }

    final pipeline = ref.read(billScanPipelineServiceProvider);

    setState(() {
      _isProcessing = true;
      _statusMessage = BillTrackerStrings.t('scan_reading', _s);
    });

    try {
      if (source == BillScanCaptureSource.pdf) {
        final picked = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        final path = picked?.files.single.path;
        if (path == null) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
          return;
        }
        setState(() {
          _statusMessage = BillTrackerStrings.t('scan_extracting', _s);
        });
        final result = await pipeline.runFromPdfPath(path);
        if (result == null && mounted) {
          _showSnack(BillTrackerStrings.t('scan_pdf_no_text', _s));
        }
        await _finishPipeline(result);
        return;
      }

      final result = await pipeline.runFromCapture(source);
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        return;
      }

      setState(() {
        _statusMessage = BillTrackerStrings.t('scan_extracting', _s);
      });

      await _finishPipeline(result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
      _showSnack(BillTrackerStrings.t('scan_process_error', _s));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(billScanPipelineServiceProvider);

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
            const GlassProgressIndicator(
              color: AppColors.sharePurple,
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage ?? BillTrackerStrings.t('scan_processing', _s),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.6),
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
          color: AppColors.sharePurple.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.document_scanner_rounded,
                color: AppColors.sharePurple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  BillTrackerStrings.t('scan_import_title', _s),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                BillTrackerStrings.t('scan_ai_powered', _s),
                style: TextStyle(
                  color: AppColors.sharePurple.withValues(alpha: 0.6),
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
                  onPressed: pipeline.supportsDocumentCamera
                      ? () => _runPipeline(BillScanCaptureSource.camera)
                      : null,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    BillTrackerStrings.t('scan_camera', _s),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sharePurple,
                    disabledBackgroundColor:
                        AppColors.sharePurple.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _runPipeline(BillScanCaptureSource.gallery),
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.accentGold,
                    size: 16,
                  ),
                  label: Text(
                    BillTrackerStrings.t('scan_gallery', _s),
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: BorderSide(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _runPipeline(BillScanCaptureSource.pdf),
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.cyanGlow,
              size: 18,
            ),
            label: Text(
              BillTrackerStrings.t('scan_import_pdf', _s),
              style: const TextStyle(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(
                color: AppColors.cyanGlow.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            BillTrackerStrings.t('scan_import_subtitle', _s),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  BillTrackerStrings.t('import_text_divider', _s),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          BillTextImportSection(
            locale: _s,
            compact: true,
            onPipelineComplete: (result) async {
              await _finishPipeline(result);
            },
          ),
        ],
      ),
    );
  }
}
