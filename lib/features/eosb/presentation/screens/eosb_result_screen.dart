import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/features/eosb/domain/rules/employment_coverage_rules.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_comparison_widget.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_breakdown_row.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_breakdown_chart.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_labour_dispute_escalation_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/home_country_support_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_panel.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hero_card.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_transition_awareness_section.dart';
import 'package:raabta/features/welcome_home/presentation/l10n/welcome_home_strings.dart';
import 'package:raabta/features/welcome_home/presentation/screens/welcome_home_screen.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_loading_skeleton.dart';
import 'package:raabta/features/eosb/providers/eosb_certificate_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_generation_service.dart';
import 'package:raabta/providers/app_update_provider.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_article_62_result_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_result_truth_banners.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

class EosbResultScreen extends ConsumerWidget {
  const EosbResultScreen({super.key, this.showLegalUpdateBanner = false});

  final bool showLegalUpdateBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final result = ref.watch(eosbProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: EosbResultSkeleton(),
      ),
      error: (_, _) => GlassScreenScaffold(
        title: 'EOSB',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: GlassEmptyState(
            icon: Icons.calculate_outlined,
            title: EosbStrings.t('eosb_empty_result_title', 'English'),
            description: EosbStrings.t('eosb_empty_result_desc', 'English'),
            actionLabel: EosbStrings.t('eosb_calculate_cta', 'English'),
            onAction: () => context.push('/eosb/employee-info'),
          ),
        ),
      ),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_results', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: Center(
              child: GlassEmptyState(
              icon: Icons.calculate_outlined,
              title: EosbStrings.t('eosb_empty_result_title', locale),
              description: EosbStrings.t('eosb_empty_result_desc', locale),
              actionLabel: EosbStrings.t('eosb_calculate_cta', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          ),
          );
        }

        final input = ref.watch(eosbProvider).input;
        final isReferenceEstimate =
            EmploymentCoverageRules.isReferenceCalculation(input);

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_results', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              if (isReferenceEstimate) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: AppColors.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EosbStrings.t('eosb_reference_banner_title', locale),
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.accentGold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          EosbStrings.t('eosb_reference_banner_body', locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (showLegalUpdateBanner)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: MaterialBanner(
                    content: Text(
                      EosbStrings.t('eosb_legal_update_banner', locale),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            context.push('/eosb/employee-info?legalUpdate=1'),
                        child: Text(
                          EosbStrings.t('eosb_legal_update_recalculate', locale),
                        ),
                      ),
                    ],
                  ),
                ),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.md),
              EosbHeroCard(
                amount: result.totalEntitlement,
                locale: locale,
                result: result,
                confidenceScore: result.explanation.confidenceScore,
                isReferenceEstimate: isReferenceEstimate,
              ),
              const SizedBox(height: AppSpacing.md),
              EosbResultTruthBanners(
                locale: locale,
                result: result,
                isReferenceEstimate: isReferenceEstimate,
              ),
              if (result.warnings.isNotEmpty || result.violations.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _LegalWarningsBanner(
                  locale: locale,
                  warningCount: result.warnings.length,
                  violationCount: result.violations.length,
                  onTap: () => context.push('/eosb/warnings'),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              LegalDeadlineEngineWidgets.eosb(
                locale: locale,
                input: input,
              ),
              const SizedBox(height: AppSpacing.lg),
              EmployerTrackRecordPanel(
                companyName: input.companyName,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              EosbBreakdownChart(result: result, locale: locale),
              const SizedBox(height: AppSpacing.lg),
              ...result.breakdown.map(
                (item) => EosbBreakdownRow(
                  item: item,
                  locale: locale,
                  onExpand: () => showEosbBreakdownSheet(
                    context,
                    item: item,
                    locale: locale,
                  ),
                ),
              ),
              if (result.comparison != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  EosbStrings.t('eosb_comparison', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                EosbComparisonWidget(
                  comparison: result.comparison!,
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/eosb/comparison'),
                    child: Text(EosbStrings.t('eosb_comparison_details', locale)),
                  ),
                ),
              ],
              EosbArticle62ResultSection(
                locale: locale,
                input: input,
                result: result,
              ),
              const SizedBox(height: AppSpacing.md),
              EosbTransitionAwarenessSection(locale: locale),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push(WelcomeHomeScreen.route),
                  icon: const Icon(Icons.home_work_outlined, size: 18),
                  label: Text(WelcomeHomeStrings.t('wh_eosb_link', locale)),
                ),
              ),
              EosbLabourDisputeEscalationSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              HomeCountrySupportSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/eosb/legal-review'),
                      icon: const Icon(Icons.gavel_outlined),
                      label: Text(EosbStrings.t('eosb_legal_review', locale)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final comparison = result.comparison;
                        ShareCardSheet.show(
                          context,
                          EosbSettlementCardData(
                            estimatedEosb: result.totalEntitlement,
                            confidenceScore:
                                (result.explanation.confidenceScore * 100)
                                    .round(),
                            employerOffer: comparison?.employerOffer,
                            difference: comparison?.difference,
                            isUnderpaid: comparison?.isUnderpaid ?? false,
                            calculatedAt: result.calculatedAt,
                            shareCaption:
                                'My estimated Qatar EOSB: ${formatEosbCurrency(result.totalEntitlement)} — calculated with RAABTA',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: Text(EosbStrings.t('eosb_share', locale)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final packageInfo =
                          await ref.read(packageInfoProvider.future);
                      if (!context.mounted) return;
                      final certGen =
                          ref.read(eosbCertificateGenerationServiceProvider);
                      final base = certGen.build(
                        result: result,
                        input: ref.read(eosbProvider).input,
                        appVersion: packageInfo.version,
                        appBuildNumber: packageInfo.buildNumber,
                        locale: locale,
                      );
                      final cached = registeredCertificateCacheEntry(
                        ref,
                        base.snapshot.certificateId,
                      );
                      final bundle = cached == null
                          ? base
                          : certGen.buildRegistered(
                              snapshot: base.snapshot,
                              locale: locale,
                              verificationUrl: cached.verificationUrl,
                              cryptographicallySigned:
                                  cached.cryptographicallySigned,
                            );
                      if (!context.mounted) return;
                      ShareCardSheet.show(
                        context,
                        EosbTruthCertificateCardData(
                          presentation: bundle.presentation,
                          shareCaption: EosbCertificateStrings.format(
                            'eosb_cert_total_entitlement',
                            locale,
                            {
                              'amount':
                                  bundle.presentation.entitlementAmountDisplay,
                            },
                          ),
                        ),
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              EosbCertificateStrings.t(
                                'eosb_cert_error_share',
                                locale,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(
                    EosbCertificateStrings.t('eosb_cert_share_card', locale),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    try {
                      final packageInfo =
                          await ref.read(packageInfoProvider.future);
                      if (!context.mounted) return;
                      final certGen =
                          ref.read(eosbCertificateGenerationServiceProvider);
                      final base = certGen.build(
                        result: result,
                        input: ref.read(eosbProvider).input,
                        appVersion: packageInfo.version,
                        appBuildNumber: packageInfo.buildNumber,
                        locale: locale,
                      );
                      final outcome = await registerEosbCertificateBundle(
                        ref: ref,
                        snapshot: base.snapshot,
                        locale: locale,
                      );
                      if (!context.mounted) return;
                      if (outcome.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              EosbCertificateStrings.t(
                                'eosb_cert_register_success',
                                locale,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final message =
                            outcome.error == 'rate_limit_exceeded'
                                ? EosbCertificateStrings.t(
                                    'eosb_cert_register_rate_limit',
                                    locale,
                                  )
                                : EosbCertificateStrings.t(
                                    'eosb_cert_register_error',
                                    locale,
                                  );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              EosbCertificateStrings.t(
                                'eosb_cert_register_error',
                                locale,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    EosbCertificateStrings.t('eosb_cert_register_online', locale),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalWarningsBanner extends StatelessWidget {
  const _LegalWarningsBanner({
    required this.locale,
    required this.warningCount,
    required this.violationCount,
    required this.onTap,
  });

  final String locale;
  final int warningCount;
  final int violationCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = warningCount + violationCount;
    final hasViolations = violationCount > 0;
    final accent = hasViolations ? AppColors.errorBright : AppColors.accentGold;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accent,
      glowIntensity: 0.16,
      child: Row(
        children: [
          Icon(
            hasViolations ? Icons.report_outlined : Icons.warning_amber_rounded,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbStrings.t('eosb_warnings_banner_title', locale),
                  style: AppTypography.title.copyWith(
                    fontSize: 14,
                    color: accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  EosbStrings.t('eosb_warnings_banner_body', locale)
                      .replaceAll('{count}', '$total'),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
