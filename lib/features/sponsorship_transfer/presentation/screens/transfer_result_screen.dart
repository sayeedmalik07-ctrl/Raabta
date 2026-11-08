import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/core/widgets/truth_engine_result_skeleton.dart';
import 'package:raabta/core/widgets/truth_engine_secondary_actions.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_active_transfer_protection_banner.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_employer_cost_section.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/transfer_readiness_summary_card.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';

class TransferResultScreen extends ConsumerWidget {
  const TransferResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final result = ref.watch(sponsorshipTransferProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: TruthEngineResultSkeleton(),
      ),
      error: (_, _) => const GlassScreenScaffold(
        body: TruthEngineResultSkeleton(),
      ),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: SponsorshipTransferStrings.t('st_results_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.swap_horiz,
              title: SponsorshipTransferStrings.t('st_form_title', locale),
              description: SponsorshipTransferStrings.t('st_results_empty', locale),
              actionLabel: SponsorshipTransferStrings.t('st_dashboard_cta', locale),
              onAction: () => context.push('/sponsorship-transfer/readiness'),
            ),
          );
        }

        final showCritical = result.hasCriticalIssue;
        final showWarning = !showCritical && result.hasWarning;
        final showChecklistPrimary = showCritical || showWarning;
        final primaryItems = result.items
            .where((i) => i.status != TransferReadinessStatus.informational)
            .toList();
        final infoItems = result.items
            .where((i) => i.status == TransferReadinessStatus.informational)
            .toList();

        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_results_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.md),
              TransferReadinessSummaryCard(
                key: const Key('st_summary'),
                result: result,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.md),
              if (showCritical) ...[
                SponsorshipTransferCriticalBanner(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ] else if (showWarning) ...[
                SponsorshipTransferWarningBanner(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ],
              SponsorshipTransferActiveTransferProtectionBanner(
                key: const Key('st_protection'),
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.md),
              if (showChecklistPrimary) ...[
                GlassPrimaryButton(
                  key: const Key('st_primary_cta'),
                  label: SponsorshipTransferStrings.t(
                    'st_dashboard_checklist_cta',
                    locale,
                  ),
                  icon: Icons.checklist_outlined,
                  expand: true,
                  accentColor: AppColors.chipSponsorshipTransfer,
                  onPressed: () => context.push('/sponsorship-transfer/checklist'),
                ),
                const SizedBox(height: AppSpacing.md),
              ] else ...[
                GlassPrimaryButton(
                  key: const Key('st_primary_cta'),
                  label: SponsorshipTransferStrings.t('st_edit_details', locale),
                  expand: true,
                  accentColor: AppColors.chipSponsorshipTransfer,
                  onPressed: () => context.push('/sponsorship-transfer/readiness'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (result.monthsEmployed != null) ...[
                Text(
                  SponsorshipTransferStrings.t(
                    result.items
                        .firstWhere((i) => i.id == 'notice_period')
                        .explanationKey,
                    locale,
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.chipSponsorshipTransfer,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (var i = 0; i < primaryItems.length; i++) ...[
                TransferReadinessResultCard(
                  key: i == 0 ? const Key('st_first_finding') : null,
                  item: primaryItems[i],
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (infoItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  SponsorshipTransferStrings.t('st_status_informational', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in infoItems) ...[
                  TransferReadinessResultCard(item: item, locale: locale),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
              LegalDeadlineEngineWidgets.sponsorshipTransfer(
                locale: locale,
                input: ref.watch(sponsorshipTransferProvider).input,
              ),
              const SizedBox(height: AppSpacing.md),
              SponsorshipTransferEmployerCostSection(
                key: const Key('st_employer_cost'),
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              TruthEngineSecondaryActions(
                topSpacing: AppSpacing.lg,
                actions: [
                  if (showChecklistPrimary)
                    TruthEngineSecondaryAction(
                      label: SponsorshipTransferStrings.t('st_edit_details', locale),
                      onPressed: () => context.push('/sponsorship-transfer/readiness'),
                    )
                  else
                    TruthEngineSecondaryAction(
                      label: SponsorshipTransferStrings.t(
                        'st_dashboard_checklist_cta',
                        locale,
                      ),
                      icon: Icons.checklist_outlined,
                      onPressed: () => context.push('/sponsorship-transfer/checklist'),
                    ),
                  TruthEngineSecondaryAction(
                    label: SponsorshipTransferStrings.t('st_dashboard_ai_cta', locale),
                    icon: Icons.chat_outlined,
                    onPressed: () => context.push('/sponsorship-transfer/ai-assistant'),
                  ),
                  TruthEngineSecondaryAction(
                    label: SponsorshipTransferStrings.t('st_visa_guide_link', locale),
                    icon: Icons.open_in_new,
                    style: TruthEngineSecondaryActionStyle.textLink,
                    onPressed: () => context.push('/visa/guide/sponsor_transfer'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
