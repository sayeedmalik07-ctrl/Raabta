import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_comparison_widget.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_confidence_sheet.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_summary_charts.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_pdf_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

class OvertimeSummaryScreen extends ConsumerWidget {
  const OvertimeSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final result = ref.watch(overtimeTruthProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('ot_monthly_summary', locale),
            body: GlassEmptyState(
              icon: Icons.analytics_outlined,
              title: EosbStrings.t('ot_empty_title', locale),
              description: EosbStrings.t('ot_empty_desc', locale),
              actionLabel: EosbStrings.t('ot_calendar_mode', locale),
              onAction: () => context.push('/eosb/overtime/calendar'),
            ),
          );
        }

        final s = result.summary;

        return GlassScreenScaffold(
          title: EosbStrings.t('ot_monthly_summary', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.accentGold,
                glowIntensity: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.record.label,
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      formatEosbCurrency(s.totalPayment),
                      style: AppTypography.display.copyWith(fontSize: 34),
                    ),
                    Text(
                      '${s.totalHours.toStringAsFixed(1)} ${EosbStrings.t('ot_total_ot_hours', locale)}',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => showOvertimeConfidenceSheet(
                        context,
                        locale: locale,
                        result: result,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 16,
                            color: AppColors.cyanGlow,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${EosbStrings.t('ot_confidence', locale)} ${result.confidenceScore}%',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.cyanGlow,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _HoursRow(
                locale: locale,
                regular: s.regularDayHours,
                rest: s.restDayHours,
                holiday: s.holidayHours,
                night: s.nightHours,
              ),
              const SizedBox(height: AppSpacing.lg),
              OvertimeSummaryCharts(result: result, locale: locale),
              const SizedBox(height: AppSpacing.lg),
              OvertimeRateBreakdownCard(result: result, locale: locale),
              const SizedBox(height: AppSpacing.lg),
              OvertimeComparisonWidget(
                comparison: result.comparison,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_ai_review', locale),
                expand: true,
                accentColor: AppColors.sharePurple,
                icon: Icons.auto_awesome,
                onPressed: () => context.push('/eosb/overtime/ai-review'),
              ),
              const SizedBox(height: AppSpacing.sm),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_share_card', locale),
                expand: true,
                accentColor: AppColors.emeraldGlow,
                icon: Icons.share_outlined,
                onPressed: () {
                  ShareCardSheet.show(
                    context,
                    OvertimeTruthCardData(
                      monthLabel: result.record.label,
                      companyName: result.record.profile.companyName,
                      totalHours: result.totalOvertimeHours,
                      estimatedAmount: result.totalLegalOwed,
                      employerPaid: result.comparison.employerPaid,
                      difference: result.comparison.unpaidGap,
                      currency: result.record.profile.currency,
                      shareCaption: EosbStrings.t('ot_report_share', locale),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_share_report', locale),
                expand: true,
                accentColor: AppColors.cyanGlow,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () async {
                  final pdf = ref.read(overtimePdfServiceProvider);
                  final file = await pdf.generateReport(
                    result: result,
                    locale: locale,
                  );
                  await pdf.shareReport(file, locale);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.locale,
    required this.regular,
    required this.rest,
    required this.holiday,
    required this.night,
  });

  final String locale;
  final double regular;
  final double rest;
  final double holiday;
  final double night;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _chip(EosbStrings.t('ot_cat_weekday', locale), regular),
        _chip(EosbStrings.t('ot_cat_restday', locale), rest),
        _chip(EosbStrings.t('ot_cat_holiday', locale), holiday),
        _chip(EosbStrings.t('ot_cat_night', locale), night),
      ],
    );
  }

  Widget _chip(String label, double hours) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          Text('${hours.toStringAsFixed(1)}h', style: AppTypography.title),
        ],
      ),
    );
  }
}
