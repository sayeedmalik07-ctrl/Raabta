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
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

/// Hub for move-in / move-out condition records.
class TenancyConditionHubScreen extends ConsumerWidget {
  const TenancyConditionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final tenancy = ref.watch(tenancyProvider);
    final recordsAsync = ref.watch(tenancyConditionRecordsProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (tenancy.result == null) {
          return GlassScreenScaffold(
            title: TenancyStrings.t('tenancy_condition_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.home_work_outlined,
              title: TenancyStrings.t('tenancy_condition_need_lease', locale),
              description: TenancyStrings.t('tenancy_dashboard_cta', locale),
              actionLabel: TenancyStrings.t('tenancy_dashboard_cta', locale),
              onAction: () => context.push('/tenancy/lease-entry'),
            ),
          );
        }

        final input = tenancy.input;
        final showMoveOutPrompt = tenancyLeaseEndApproaching(input.leaseEndDate);

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_condition_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(
              TenancyStrings.t('tenancy_condition_load_error', locale),
            ),
            data: (records) {
              final moveIn = records
                  .where((r) => r.recordType == TenancyConditionRecordType.moveIn)
                  .toList();
              final moveOut = records
                  .where((r) => r.recordType == TenancyConditionRecordType.moveOut)
                  .toList();
              final latestMoveIn =
                  moveIn.isNotEmpty ? moveIn.last : null;
              final latestMoveOut =
                  moveOut.isNotEmpty ? moveOut.last : null;
              final canCompare =
                  latestMoveIn != null && latestMoveOut != null;

              return ListView(
                children: [
                  TenancyDisclaimerBanner(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    TenancyStrings.t('tenancy_condition_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (latestMoveIn == null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      glowColor: AppColors.chipEosb,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            TenancyStrings.t(
                              'tenancy_condition_move_in_cta',
                              locale,
                            ),
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            TenancyStrings.t(
                              'tenancy_condition_move_in_hint',
                              locale,
                            ),
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassPrimaryButton(
                            label: TenancyStrings.t(
                              'tenancy_condition_start_move_in',
                              locale,
                            ),
                            icon: Icons.camera_alt_outlined,
                            expand: true,
                            accentColor: AppColors.chipEosb,
                            onPressed: () => context.push(
                              '/tenancy/condition/capture?type=moveIn',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    _RecordSummaryCard(
                      locale: locale,
                      record: latestMoveIn,
                      onRecapture: () => context.push(
                        '/tenancy/condition/capture?type=moveIn',
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (showMoveOutPrompt || latestMoveIn != null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      glowColor: AppColors.accentGold,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            TenancyStrings.t(
                              'tenancy_condition_move_out_cta',
                              locale,
                            ),
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            TenancyStrings.t(
                              'tenancy_condition_move_out_hint',
                              locale,
                            ),
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassPrimaryButton(
                            label: TenancyStrings.t(
                              'tenancy_condition_start_move_out',
                              locale,
                            ),
                            icon: Icons.logout_outlined,
                            expand: true,
                            accentColor: AppColors.accentGold,
                            onPressed: () => context.push(
                              '/tenancy/condition/capture?type=moveOut',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (latestMoveOut != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _RecordSummaryCard(
                        locale: locale,
                        record: latestMoveOut,
                        onRecapture: () => context.push(
                          '/tenancy/condition/capture?type=moveOut',
                        ),
                      ),
                    ],
                  ],
                  if (canCompare) ...[
                    const SizedBox(height: AppSpacing.lg),
                    GlassPrimaryButton(
                      label: TenancyStrings.t(
                        'tenancy_condition_compare_cta',
                        locale,
                      ),
                      icon: Icons.compare_outlined,
                      expand: true,
                      onPressed: () => context.push('/tenancy/condition/compare'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/tenancy/condition/report',
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      TenancyStrings.t(
                        'tenancy_condition_export_pdf',
                        locale,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _RecordSummaryCard extends StatelessWidget {
  const _RecordSummaryCard({
    required this.locale,
    required this.record,
    required this.onRecapture,
  });

  final String locale;
  final TenancyConditionRecord record;
  final VoidCallback onRecapture;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TenancyStrings.t(record.recordType.labelKey, locale),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            TenancyStrings.format('tenancy_condition_summary', locale, {
              'rooms': record.rooms.length.toString(),
              'photos': record.totalPhotos.toString(),
            }),
            style: AppTypography.caption,
          ),
          TextButton(
            onPressed: onRecapture,
            child: Text(
              TenancyStrings.t('tenancy_condition_recapture', locale),
            ),
          ),
        ],
      ),
    );
  }
}
