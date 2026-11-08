import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/quick_actions/warranty_shield/services/warranty_scan_pipeline_service.dart';

class WarrantyScanWidget extends ConsumerStatefulWidget {
  const WarrantyScanWidget({
    super.key,
    required this.locale,
    required this.onItemSaved,
  });

  final String locale;
  final Future<void> Function(WarrantyItem item) onItemSaved;

  @override
  ConsumerState<WarrantyScanWidget> createState() => _WarrantyScanWidgetState();
}

class _WarrantyScanWidgetState extends ConsumerState<WarrantyScanWidget> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _runPipeline(BillScanCaptureSource source) async {
    if (source == BillScanCaptureSource.camera && isScannerDesktop) {
      _showSnack(WarrantyStrings.t('warr_scan_camera_macos', widget.locale));
      return;
    }

    final pipeline = ref.read(warrantyScanPipelineServiceProvider);

    setState(() {
      _isProcessing = true;
      _statusMessage = BillTrackerStrings.t('scan_reading', widget.locale);
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
        _showSnack(BillTrackerStrings.t('scan_no_text', widget.locale));
        return;
      }

      setState(() {
        _statusMessage = BillTrackerStrings.t('scan_extracting', widget.locale);
      });

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });

      final item = await context.push<WarrantyItem>(
        '/warranty-shield/scan/review',
        extra: {
          'extraction': result.extraction,
          'imagePath': result.imagePaths.isNotEmpty
              ? result.imagePaths.first
              : '',
        },
      );
      if (item != null) {
        await widget.onItemSaved(item);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
      _showSnack(BillTrackerStrings.t('scan_process_error', widget.locale));
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
    if (_isProcessing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.successBright.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.successBright,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage ??
                  BillTrackerStrings.t('scan_processing', widget.locale),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.successBright.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WarrantyStrings.t('warr_scan_receipt_title', widget.locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textPrimary
                  : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WarrantyStrings.t('warr_scan_receipt_sub', widget.locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _runPipeline(BillScanCaptureSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: Text(BillTrackerStrings.t('scan_camera', widget.locale)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successBright,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _runPipeline(BillScanCaptureSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: Text(
                    BillTrackerStrings.t('scan_gallery', widget.locale),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
        ],
      ),
    );
  }
}
