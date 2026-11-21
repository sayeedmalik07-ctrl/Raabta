import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/domain/models/insurance_compliance_history_entry.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';

class InsuranceComplianceHistoryScreen extends ConsumerWidget {
  const InsuranceComplianceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final historyAsync = ref.watch(insuranceComplianceHistoryProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) => GlassScreenScaffold(
        title: HealthInsuranceStrings.t('hi_history', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(HealthInsuranceStrings.t('hi_history_error', locale)),
          ),
          data: (history) {
            if (history.isEmpty) {
              return GlassEmptyState(
                icon: Icons.history,
                title: HealthInsuranceStrings.t('hi_empty_history', locale),
                description: HealthInsuranceStrings.t(
                  'hi_empty_history_desc',
                  locale,
                ),
                actionLabel: HealthInsuranceStrings.t(
                  'hi_dashboard_compliance_cta',
                  locale,
                ),
                onAction: () => context.push('/health-insurance/compliance'),
              );
            }

            final dateFormat = DateFormat.yMMMd().add_jm();

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final summary = _summaryFor(entry, locale);
                final badgeColor = entry.hasUnresolvedViolation
                    ? AppColors.errorBright
                    : AppColors.successBright;
                final badgeLabel = entry.hasUnresolvedViolation
                    ? HealthInsuranceStrings.t('hi_status_violation', locale)
                    : HealthInsuranceStrings.t('hi_status_compliant', locale);

                return GlassCard(
                  onTap: () => context.push(
                    '/health-insurance/compliance/history/${entry.id}',
                    extra: entry,
                  ),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(summary, style: AppTypography.title),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              dateFormat.format(entry.checkedAt.toLocal()),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXs),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: AppTypography.chipLabel.copyWith(
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _summaryFor(
    InsuranceComplianceHistoryEntry entry,
    String locale,
  ) {
    if (entry.companyName.trim().isNotEmpty) {
      return entry.companyName.trim();
    }
    return entry.hasUnresolvedViolation
        ? HealthInsuranceStrings.t('hi_history_summary_violation', locale)
        : HealthInsuranceStrings.t('hi_history_summary_compliant', locale);
  }
}

class InsuranceComplianceHistoryDetailScreen extends ConsumerWidget {
  const InsuranceComplianceHistoryDetailScreen({
    super.key,
    required this.entry,
  });

  final InsuranceComplianceHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final dateFormat = DateFormat.yMMMd().add_jm();
        final statusColor = entry.hasUnresolvedViolation
            ? AppColors.errorBright
            : AppColors.successBright;
        final statusLabel = entry.hasUnresolvedViolation
            ? HealthInsuranceStrings.t('hi_status_violation', locale)
            : HealthInsuranceStrings.t('hi_status_compliant', locale);

        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_history_detail_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              HealthInsuranceDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.cyanGlow.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  HealthInsuranceStrings.t('hi_history_detail_note', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(entry.checkedAt.toLocal()),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (entry.companyName.trim().isNotEmpty) ...[
                      Text(
                        HealthInsuranceStrings.t('hi_history_detail_employer', locale),
                        style: AppTypography.caption,
                      ),
                      Text(
                        entry.companyName.trim(),
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      HealthInsuranceStrings.t('hi_history_detail_status', locale),
                      style: AppTypography.caption,
                    ),
                    Text(
                      statusLabel,
                      style: AppTypography.title.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () => context.push('/health-insurance/compliance'),
                child: Text(
                  HealthInsuranceStrings.t('hi_dashboard_compliance_cta', locale),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
