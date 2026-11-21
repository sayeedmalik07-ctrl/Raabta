import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/l10n/food_inspector_strings.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/services/expiry_date_scan_service.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/services/expiry_label_scan_pipeline.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/services/product_expiry_reminder_service.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/widgets/food_inspector_theme.dart';

class ExpiryDateScanSheet extends ConsumerStatefulWidget {
  const ExpiryDateScanSheet({super.key, required this.locale});

  final String locale;

  static Future<void> show(BuildContext context, String locale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
              border: Border.all(
                color: foodInspectorPurple.withValues(alpha: 0.25),
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: ExpiryDateScanSheet(locale: locale),
            ),
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<ExpiryDateScanSheet> createState() =>
      _ExpiryDateScanSheetState();
}

class _ExpiryDateScanSheetState extends ConsumerState<ExpiryDateScanSheet> {
  bool _loading = false;
  String? _error;
  ExpiryDateScanResult? _result;
  DateTime? _confirmedDate;
  bool _reminderScheduled = false;

  Future<void> _runOcr(Future<String?> Function() capture) async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _confirmedDate = null;
      _reminderScheduled = false;
    });

    try {
      final text = await capture();
      if (!mounted) return;
      if (text == null || text.trim().isEmpty) {
        setState(() {
          _error = FoodInspectorStrings.t('expiry_ocr_empty', widget.locale);
          _loading = false;
        });
        return;
      }

      final parsed = await ref
          .read(expiryDateScanServiceProvider)
          .parseOcrText(ocrText: text, uiLanguage: widget.locale);

      if (!mounted) return;
      setState(() {
        _result = parsed;
        _confirmedDate = parsed.resolvedDate;
        _loading = false;
        if (parsed.candidates.isEmpty) {
          _error = FoodInspectorStrings.t('expiry_parse_failed', widget.locale);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = FoodInspectorStrings.t('expiry_parse_failed', widget.locale);
        _loading = false;
      });
    }
  }

  Future<void> _scheduleReminder() async {
    final date = _confirmedDate;
    if (date == null) return;

    final id = 'expiry_${date.millisecondsSinceEpoch}';
    await ProductExpiryReminderService.schedule(
      reminderId: id,
      productLabel: FoodInspectorStrings.t('expiry_reminder_product', widget.locale),
      expiryDate: date,
    );
    if (mounted) {
      setState(() => _reminderScheduled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FoodInspectorStrings.t('expiry_reminder_set', widget.locale),
          ),
        ),
      );
    }
  }

  Color _daysColor(int days) {
    if (days < 0) return AppColors.errorBright;
    if (days <= 3) return AppColors.heatOrange;
    if (days <= 14) return AppColors.accentGold;
    return AppColors.successBright;
  }

  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(expiryLabelScanPipelineProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textOnGlassMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          FoodInspectorStrings.t('expiry_scan_title', widget.locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          FoodInspectorStrings.t('expiry_scan_subtitle', widget.locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: foodInspectorGold))
        else ...[
          GlassPrimaryButton(
            label: FoodInspectorStrings.t('expiry_capture_cta', widget.locale),
            icon: Icons.photo_camera_outlined,
            expand: true,
            accentColor: foodInspectorPurple,
            onPressed: pipeline.supportsDocumentCamera
                ? () => _runOcr(pipeline.captureAndOcr)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: GlassSecondaryButton(
              label: FoodInspectorStrings.t('expiry_gallery_cta', widget.locale),
              icon: Icons.photo_library_outlined,
              onPressed: () => _runOcr(pipeline.pickGalleryAndOcr),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTypography.caption.copyWith(color: AppColors.errorBright),
          ),
        ],
        if (_result != null && _result!.candidates.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          if (_result!.isAmbiguous) ...[
            Text(
              FoodInspectorStrings.t('expiry_ambiguous_title', widget.locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: 6),
            Text(
              _result!.notes ??
                  FoodInspectorStrings.t(
                    'expiry_ambiguous_body',
                    widget.locale,
                  ),
              style: AppTypography.caption.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._result!.candidates.map((d) {
              final label =
                  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _confirmedDate = d),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _confirmedDate == d
                        ? foodInspectorGold
                        : AppColors.textPrimary,
                    side: BorderSide(
                      color: _confirmedDate == d
                          ? foodInspectorGold
                          : AppColors.textOnGlassMuted.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(label),
                ),
              );
            }),
          ] else if (_confirmedDate != null) ...[
            _ExpiryCountdown(
              expiryDate: _confirmedDate!,
              locale: widget.locale,
              colorForDays: _daysColor,
            ),
          ],
          if (_confirmedDate != null && !_reminderScheduled) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: GlassSecondaryButton(
                label:
                    FoodInspectorStrings.t('expiry_reminder_cta', widget.locale),
                icon: Icons.notifications_outlined,
                onPressed: _scheduleReminder,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ExpiryCountdown extends StatelessWidget {
  const _ExpiryCountdown({
    required this.expiryDate,
    required this.locale,
    required this.colorForDays,
  });

  final DateTime expiryDate;
  final String locale;
  final Color Function(int days) colorForDays;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final expiryDay =
        DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final days = expiryDay.difference(todayDay).inDays;
    final color = colorForDays(days);

    final message = days < 0
        ? FoodInspectorStrings.format(
            'expiry_days_past',
            locale,
            {'days': '${days.abs()}'},
          )
        : days == 0
            ? FoodInspectorStrings.t('expiry_today', locale)
            : FoodInspectorStrings.format(
                'expiry_days_left',
                locale,
                {'days': '$days'},
              );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FoodInspectorStrings.format(
              'expiry_confirmed_date',
              locale,
              {
                'date':
                    '${expiryDay.day.toString().padLeft(2, '0')}/${expiryDay.month.toString().padLeft(2, '0')}/${expiryDay.year}',
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.subtitle.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
