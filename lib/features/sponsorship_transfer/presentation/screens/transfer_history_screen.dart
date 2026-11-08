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
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_check_history_entry.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';

class TransferHistoryScreen extends ConsumerWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final historyAsync = ref.watch(transferHistoryProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) => GlassScreenScaffold(
        title: SponsorshipTransferStrings.t('st_history', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(SponsorshipTransferStrings.t('st_history_error', locale)),
          ),
          data: (history) {
            if (history.isEmpty) {
              return GlassEmptyState(
                icon: Icons.history,
                title: SponsorshipTransferStrings.t('st_empty_history', locale),
                description: SponsorshipTransferStrings.t(
                  'st_empty_history_desc',
                  locale,
                ),
                actionLabel: SponsorshipTransferStrings.t('st_dashboard_cta', locale),
                onAction: () => context.push('/sponsorship-transfer/readiness'),
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
                    ref.read(sponsorshipTransferProvider.notifier).restoreFromHistory(
                          input: entry.input,
                          result: entry.result,
                        );
                    context.push('/sponsorship-transfer/result');
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

  static String _summaryFor(TransferCheckHistoryEntry entry, String locale) {
    final result = entry.result;
    if (result.hasCriticalIssue) {
      return SponsorshipTransferStrings.t('st_history_summary_critical', locale);
    }
    if (result.hasWarning) {
      return SponsorshipTransferStrings.t('st_history_summary_warning', locale);
    }
    return SponsorshipTransferStrings.t('st_history_summary_compliant', locale);
  }

  static ({String label, Color color}) _badgeFor(
    dynamic result,
    String locale,
  ) {
    switch (result.permitWindowStatus as PermitWindowStatus) {
      case PermitWindowStatus.outsideGrace:
        return (
          label: SponsorshipTransferStrings.t(
            'st_history_permit_outside_grace',
            locale,
          ),
          color: AppColors.errorBright,
        );
      case PermitWindowStatus.graceWindow:
        return (
          label: SponsorshipTransferStrings.t(
            'st_history_permit_grace',
            locale,
          ),
          color: AppColors.accentGold,
        );
      case PermitWindowStatus.valid:
        return (
          label: SponsorshipTransferStrings.t(
            'st_history_permit_valid',
            locale,
          ),
          color: AppColors.successBright,
        );
      case PermitWindowStatus.unknown:
        return (
          label: SponsorshipTransferStrings.t('st_status_needs_verification', locale),
          color: AppColors.cyanGlow,
        );
    }
  }
}
