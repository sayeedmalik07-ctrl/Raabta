import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/features/quick_actions/bill_splitter/services/receipt_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';

class ReceiptScanWidget extends ConsumerStatefulWidget {
  const ReceiptScanWidget({
    super.key,
    required this.locale,
    this.initialPeople = const [],
  });

  final String locale;
  final List<SplitPerson> initialPeople;

  @override
  ConsumerState<ReceiptScanWidget> createState() => _ReceiptScanWidgetState();
}

class _ReceiptScanWidgetState extends ConsumerState<ReceiptScanWidget> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _runPipeline(BillScanCaptureSource source) async {
    if (source == BillScanCaptureSource.camera && isScannerDesktop) {
      _showSnack(BillSplitterStrings.scanCameraMacos(widget.locale));
      return;
    }

    final pipeline = ref.read(receiptScanPipelineServiceProvider);

    setState(() {
      _isProcessing = true;
      _statusMessage = BillSplitterStrings.scanReading(widget.locale);
    });

    try {
      final result = await pipeline.runFromCapture(source);
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        return;
      }

      if (result.ocrText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        _showSnack(BillSplitterStrings.scanNoText(widget.locale));
        return;
      }

      setState(() {
        _statusMessage = BillSplitterStrings.scanExtracting(widget.locale);
      });

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });

      context.push(
        '/bill-splitter/receipt/review',
        extra: {
          'extraction': result.extraction,
          'people': widget.initialPeople,
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
      _showSnack(BillSplitterStrings.scanProcessError(widget.locale));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.isLight
            ? AppColors.surfaceElevated
            : const Color(0xFF1A1035),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(receiptScanPipelineServiceProvider);
    final locale = widget.locale;

    if (_isProcessing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassProgressIndicator(color: AppColors.accentGold),
            const SizedBox(height: 12),
            Text(
              _statusMessage ?? BillSplitterStrings.scanProcessing(locale),
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
        color: AppColors.accentGold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BillSplitterStrings.t('scan_receipt_title', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textPrimary
                  : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            BillSplitterStrings.t('scan_receipt_subtitle', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pipeline.supportsDocumentCamera
                      ? () => _runPipeline(BillScanCaptureSource.camera)
                      : null,
                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                  label: Text(BillSplitterStrings.scanCamera(locale)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        AppColors.accentGold.withValues(alpha: 0.35),
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
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: Text(BillSplitterStrings.scanGallery(locale)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGold,
                    side: BorderSide(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
