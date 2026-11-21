import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';

typedef BillTextImportComplete = void Function(BillScanPipelineResult result);

/// Paste utility bill SMS / shared text — same extraction path as photo/PDF (Part B).
class BillTextImportSection extends ConsumerStatefulWidget {
  const BillTextImportSection({
    super.key,
    required this.locale,
    required this.onPipelineComplete,
    this.initialText,
    this.compact = false,
  });

  final String locale;
  final BillTextImportComplete onPipelineComplete;
  final String? initialText;
  final bool compact;

  @override
  ConsumerState<BillTextImportSection> createState() =>
      _BillTextImportSectionState();
}

class _BillTextImportSectionState extends ConsumerState<BillTextImportSection> {
  late final TextEditingController _controller;
  bool _isProcessing = false;

  String get _s => widget.locale;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _extract() async {
    final text = _controller.text.trim();
    if (text.length < 15) {
      _snack(BillTrackerStrings.t('import_text_too_short', _s));
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final pipeline = ref.read(billScanPipelineServiceProvider);
      final result = await pipeline.runFromOcrText(text);
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result == null) {
        _snack(BillTrackerStrings.t('import_text_no_parse', _s));
        return;
      }

      widget.onPipelineComplete(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _snack(BillTrackerStrings.t('scan_process_error', _s));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: GlassProgressIndicator(color: AppColors.sharePurple),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.compact) ...[
          Text(
            BillTrackerStrings.t('import_text_title', _s),
            style: AppTypography.caption.copyWith(
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: _controller,
          maxLines: widget.compact ? 3 : 6,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
          ),
          decoration: InputDecoration(
            hintText: BillTrackerStrings.t('import_text_hint', _s),
            hintStyle: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.35),
            ),
            filled: true,
            fillColor: AppColors.isLight
                ? AppColors.textPrimary.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.sharePurple),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          BillTrackerStrings.t('import_text_disclaimer', _s),
          style: AppTypography.caption.copyWith(
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white38,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: BillTrackerStrings.t('import_text_button', _s),
          icon: Icons.text_snippet_outlined,
          expand: true,
          accentColor: AppColors.sharePurple,
          onPressed: _extract,
        ),
      ],
    );
  }
}
