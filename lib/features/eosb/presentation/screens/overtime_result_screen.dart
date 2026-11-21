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
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_comparison_widget.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_confidence_sheet.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_pdf_service.dart';

class OvertimeResultScreen extends ConsumerWidget {
  const OvertimeResultScreen({super.key});

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
            title: EosbStrings.t('ot_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.schedule,
              title: EosbStrings.t('ot_empty_title', locale),
              description: EosbStrings.t('ot_empty_desc', locale),
              actionLabel: EosbStrings.t('ot_start_calc', locale),
              onAction: () => context.push('/eosb/overtime/input'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: EosbStrings.t('ot_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              EmployerTrackRecordPanel(
                companyName: result.record.profile.companyName,
                locale: locale,
              ),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.accentGold,
                glowIntensity: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EosbStrings.t('ot_legal_owed', locale),
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      formatEosbCurrency(result.totalLegalOwed),
                      style: AppTypography.display.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _StatChip(
                          label: EosbStrings.t('ot_total_ot_hours', locale),
                          value: result.totalOvertimeHours.toStringAsFixed(1),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatChip(
                          label: EosbStrings.t('ot_confidence', locale),
                          value: '${result.confidenceScore}%',
                          onTap: () => showOvertimeConfidenceSheet(
                            context,
                            locale: locale,
                            result: result,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OvertimeComparisonWidget(
                comparison: result.comparison,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('ot_breakdown', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...result.lineItems.map(
                (item) => OvertimeBreakdownRow(
                  item: item,
                  locale: locale,
                  onExpand: () => showOvertimeBreakdownSheet(
                    context,
                    item: item,
                    locale: locale,
                  ),
                ),
              ),
              if (result.lineItems.isEmpty)
                Text(
                  EosbStrings.t('ot_alert_no_overtime_body', locale),
                  style: AppTypography.bodySmall,
                ),
              const SizedBox(height: AppSpacing.lg),
              if (result.alerts.isNotEmpty) ...[
                Text(
                  EosbStrings.t('ot_alerts', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...result.alerts.map(
                  (a) => OvertimeAlertBanner(alert: a, locale: locale),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              GlassPrimaryButton(
                label: EosbStrings.t('ot_apply_eosb', locale),
                expand: true,
                accentColor: AppColors.emeraldGlow,
                icon: Icons.link,
                onPressed: () {
                  ref.read(overtimeTruthProvider.notifier).applyToEosb();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        EosbStrings.t('ot_apply_eosb_done', locale),
                      ),
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
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_ai_explain', locale),
                expand: true,
                accentColor: AppColors.purpleGlow,
                icon: Icons.auto_awesome,
                onPressed: () => context.push('/eosb/overtime/ai-review'),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_monthly_summary', locale),
                expand: true,
                accentColor: AppColors.cyanGlow,
                icon: Icons.analytics_outlined,
                onPressed: () => context.push('/eosb/overtime/summary'),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('eosb_calculate_cta', locale),
                expand: true,
                accentColor: AppColors.accentGold,
                icon: Icons.calculate_outlined,
                onPressed: () => context.push('/eosb/employee-info'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            Row(
              children: [
                Text(value, style: AppTypography.title),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
