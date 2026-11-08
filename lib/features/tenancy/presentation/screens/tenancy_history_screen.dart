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
import 'package:raabta/features/tenancy/domain/models/tenancy_check_history_entry.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyHistoryScreen extends ConsumerWidget {
  const TenancyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final historyAsync = ref.watch(tenancyHistoryProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) => GlassScreenScaffold(
        title: TenancyStrings.t('tenancy_history', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(TenancyStrings.t('tenancy_history_error', locale)),
          ),
          data: (history) {
            if (history.isEmpty) {
              return GlassEmptyState(
                icon: Icons.history,
                title: TenancyStrings.t('tenancy_empty_history', locale),
                description: TenancyStrings.t(
                  'tenancy_empty_history_desc',
                  locale,
                ),
                actionLabel: TenancyStrings.t('tenancy_dashboard_cta', locale),
                onAction: () => context.push('/tenancy/lease-entry'),
              );
            }

            final dateFormat = DateFormat.yMMMd().add_jm();

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final summary = _summaryFor(entry, locale);
                final badge = _badgeFor(entry.result, locale);

                return GlassCard(
                  onTap: () {
                    ref.read(tenancyProvider.notifier).restoreFromHistory(
                          input: entry.input,
                          result: entry.result,
                        );
                    context.push('/tenancy/result');
                  },
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
                          color: badge.color.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXs),
                          border: Border.all(
                            color: badge.color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          badge.label,
                          style: AppTypography.chipLabel.copyWith(
                            color: badge.color,
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

  static String _summaryFor(TenancyCheckHistoryEntry entry, String locale) {
    final primary = entry.result.primaryCritical;
    if (primary != null) {
      return TenancyStrings.t(primary.titleKey, locale);
    }
    if (entry.result.hasCriticalIssue) {
      return TenancyStrings.t('tenancy_history_summary_critical', locale);
    }
    if (entry.result.hasViolation) {
      final violation = entry.result.items.firstWhere(
        (item) => item.status == TenancyComplianceStatus.violation,
        orElse: () => entry.result.items.first,
      );
      return TenancyStrings.t(violation.titleKey, locale);
    }
    return TenancyStrings.t('tenancy_history_summary_compliant', locale);
  }

  static ({String label, Color color}) _badgeFor(
    TenancyComplianceResult result,
    String locale,
  ) {
    if (result.hasCriticalIssue) {
      return (
        label: TenancyStrings.t('tenancy_status_critical', locale),
        color: AppColors.errorBright,
      );
    }
    if (result.hasViolation) {
      return (
        label: TenancyStrings.t('tenancy_status_violation', locale),
        color: AppColors.accentGold,
      );
    }
    return (
      label: TenancyStrings.t('tenancy_status_compliant', locale),
      color: AppColors.successBright,
    );
  }
}
