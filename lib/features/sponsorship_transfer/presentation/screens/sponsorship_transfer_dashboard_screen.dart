import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_employer_cost_section.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_qid_cancellation_section.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';

class SponsorshipTransferDashboardScreen extends ConsumerWidget {
  const SponsorshipTransferDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final state = ref.watch(sponsorshipTransferProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final hasResult = state.result != null;
        final critical = state.result?.hasCriticalIssue ?? false;
        final warning = state.result?.hasWarning ?? false;

        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                SponsorshipTransferStrings.t('st_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              SponsorshipTransferQidCancellationSection(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              if (hasResult && critical) ...[
                SponsorshipTransferCriticalBanner(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ] else if (hasResult && warning) ...[
                SponsorshipTransferWarningBanner(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ],
              if (hasResult) ...[
                LegalDeadlineEngineWidgets.sponsorshipTransfer(
                  locale: locale,
                  input: state.input,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.chipSponsorshipTransfer.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SponsorshipTransferSectionHeader(
                      title: SponsorshipTransferStrings.t('st_form_title', locale),
                      subtitle: SponsorshipTransferStrings.t('st_subtitle', locale),
                      icon: Icons.swap_horiz,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassPrimaryButton(
                      label: SponsorshipTransferStrings.t('st_dashboard_cta', locale),
                      expand: true,
                      accentColor: AppColors.chipSponsorshipTransfer,
                      onPressed: () => context.push('/sponsorship-transfer/readiness'),
                    ),
                    if (hasResult) ...[
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: () => context.push('/sponsorship-transfer/result'),
                        child: Text(
                          SponsorshipTransferStrings.t(
                            'st_dashboard_results_cta',
                            locale,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/sponsorship-transfer/checklist'),
                      icon: const Icon(Icons.checklist_outlined),
                      label: Text(
                        SponsorshipTransferStrings.t('st_dashboard_checklist_cta', locale),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/sponsorship-transfer/ai-assistant'),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(
                        SponsorshipTransferStrings.t('st_dashboard_ai_cta', locale),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () => context.push('/visa/guide/sponsor_transfer'),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  SponsorshipTransferStrings.t('st_visa_guide_link', locale),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SponsorshipTransferEmployerCostSection(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    SponsorshipTransferStrings.t('st_hub_explore', locale),
                    style: AppTypography.title,
                  ),
                  children: [
                    GlassCard(
                      onTap: () => context.push('/sponsorship-transfer/scenarios'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: AppColors.chipSponsorshipTransfer,
                      glowIntensity: 0.1,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights_outlined,
                            color: AppColors.chipSponsorshipTransfer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              SponsorshipTransferStrings.t('st_scenarios', locale),
                              style: AppTypography.title.copyWith(fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassCard(
                      onTap: () => context.push('/sponsorship-transfer/history'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: AppColors.textSecondary,
                      glowIntensity: 0.1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              SponsorshipTransferStrings.t('st_history', locale),
                              style: AppTypography.title.copyWith(fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
