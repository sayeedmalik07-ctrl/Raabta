import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/trip_planner/data/fair_price_guide_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/fair_price_models.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_bill_scan_widget.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/services/trip_bill_scan_ai_service.dart';

class TripBillScanScreen extends ConsumerStatefulWidget {
  const TripBillScanScreen({super.key});

  @override
  ConsumerState<TripBillScanScreen> createState() => _TripBillScanScreenState();
}

class _TripBillScanScreenState extends ConsumerState<TripBillScanScreen> {
  TripBillScanResult? _result;
  bool _processing = false;

  Future<void> _onOcr(String text) async {
    final locale = ref.read(tripPlannerProvider).preferences.locale;
    setState(() {
      _processing = true;
      _result = null;
    });

    try {
      final result = await ref.read(tripBillScanProcessorProvider).process(
            ocrText: text,
            locale: locale,
          );
      if (mounted) setState(() => _result = result);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final result = _result;

    return GlassScreenScaffold(
      title: TripStrings.t('bill_scan_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.warning,
            child: Text(
              TripStrings.t('bill_scan_disclaimer', locale),
              style: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TripBillScanWidget(
            locale: locale,
            isProcessing: _processing,
            onOcrText: _onOcr,
          ),
          if (result != null && !result.parsed.isPlausible) ...[
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.errorBright,
              child: Text(
                TripStrings.t('bill_scan_unclear', locale),
                style: AppTypography.body,
              ),
            ),
          ],
          if (result != null && result.parsed.isPlausible) ...[
            const SizedBox(height: AppSpacing.lg),
            _ResultsView(result: result, locale: locale),
          ],
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.push('/trip-planner/fair-prices'),
            child: Text(TripStrings.t('fair_price_title', locale)),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.result,
    required this.locale,
  });

  final TripBillScanResult result;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final bill = result.parsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bill.store != null)
          Text(bill.store!, style: AppTypography.title),
        if (bill.totalQar != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            TripStrings.format('bill_scan_total_paid', locale, {
              'amount': bill.totalQar!.toStringAsFixed(2),
            }),
            style: AppTypography.headline2.copyWith(
              color: AppColors.chipTrip,
              fontSize: 22,
            ),
          ),
        ],
        if (result.summary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(result.summary, style: AppTypography.body),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          TripStrings.t('bill_scan_comparison_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.comparisons.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ComparisonRow(comparison: c, locale: locale),
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.comparison,
    required this.locale,
  });

  final BillItemComparison comparison;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final accent = switch (comparison.assessment) {
      BillRangeAssessment.inTypicalRange => AppColors.successBright,
      BillRangeAssessment.belowTypical => AppColors.info,
      BillRangeAssessment.somewhatAbove => AppColors.accentGold,
      BillRangeAssessment.notablyAbove => AppColors.warning,
      BillRangeAssessment.unknown => AppColors.textSecondary,
    };

    final guide = comparison.guideItemId != null
        ? FairPriceGuideCatalog.byId(comparison.guideItemId!)
        : null;

    final typical = guide == null
        ? TripStrings.t('bill_scan_no_guide_match', locale)
        : guide.minQar == guide.maxQar
            ? TripStrings.format('fair_price_single_qar', locale, {
                'amount': guide.minQar.toStringAsFixed(
                  guide.minQar == guide.minQar.roundToDouble() ? 0 : 2,
                ),
              })
            : TripStrings.format('fair_price_range_qar', locale, {
                'min': guide.minQar.toStringAsFixed(0),
                'max': guide.maxQar.toStringAsFixed(0),
              });

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accent,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (guide != null) ...[
            TrustLabel(
              type: TrustLabelType.verified,
              locale: locale,
              verifiedDateIso: FairPriceGuideCatalog.catalogLastVerified,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(comparison.paidLabel, style: AppTypography.title.copyWith(fontSize: 14)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TripStrings.format('bill_scan_you_paid', locale, {
                  'amount': comparison.paidAmount.toStringAsFixed(2),
                }),
                style: AppTypography.bodySmall,
              ),
              Text(
                TripStrings.format('bill_scan_typical', locale, {
                  'range': typical,
                }),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _assessmentLabel(comparison.assessment, locale),
            style: AppTypography.caption.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  String _assessmentLabel(BillRangeAssessment a, String locale) {
    return switch (a) {
      BillRangeAssessment.inTypicalRange =>
        TripStrings.t('bill_assess_in_range', locale),
      BillRangeAssessment.somewhatAbove =>
        TripStrings.t('bill_assess_somewhat_above', locale),
      BillRangeAssessment.notablyAbove =>
        TripStrings.t('bill_assess_notably_above', locale),
      BillRangeAssessment.belowTypical =>
        TripStrings.t('bill_assess_below', locale),
      BillRangeAssessment.unknown =>
        TripStrings.t('bill_assess_unknown', locale),
    };
  }
}
