import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_link_button.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class LegalReviewScreen extends ConsumerStatefulWidget {
  const LegalReviewScreen({super.key});

  @override
  ConsumerState<LegalReviewScreen> createState() => _LegalReviewScreenState();
}

class _LegalReviewScreenState extends ConsumerState<LegalReviewScreen> {
  int _refreshTick = 0;

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    // ignore: unused_local_variable
    final _ = _refreshTick;
    const request = EosbLegalReviewRequest();
    final review = ref.watch(eosbLegalReviewProvider(request));

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final result = ref.watch(eosbProvider).result;
        if (result == null || review == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_legal_review', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.gavel_outlined,
              title: EosbStrings.t('eosb_empty_result_title', locale),
              description: EosbStrings.t('eosb_empty_result_desc', locale),
              actionLabel: EosbStrings.t('eosb_calculate_cta', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_legal_review', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _refreshTick++),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(EosbStrings.t('eosb_ai_regenerate', locale)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (review.summary != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(review.summary!, style: AppTypography.body),
                ),
              ..._section(
                locale,
                'eosb_missing_benefits',
                review.missingBenefits,
                AppColors.accentGold,
              ),
              ..._section(
                locale,
                'eosb_possible_underpayment',
                review.possibleUnderpayments,
                AppColors.errorBright,
              ),
              ..._section(
                locale,
                'eosb_labour_law_issues',
                review.labourLawIssues,
                AppColors.cyanGlow,
              ),
              ..._section(
                locale,
                'eosb_contract_risks',
                review.contractRisks,
                AppColors.heatOrange,
              ),
              ..._section(
                locale,
                'eosb_next_steps',
                review.nextSteps,
                AppColors.emeraldGlow,
              ),
              ..._section(
                locale,
                'eosb_negotiation_advice',
                review.negotiationAdvice,
                AppColors.sharePurple,
              ),
              ..._section(
                locale,
                'eosb_required_documents',
                review.requiredDocuments,
                AppColors.info,
              ),
              ..._section(
                locale,
                'eosb_deadlines',
                review.deadlines,
                AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
              CaseTimelineLinkButton(
                engine: CaseTimelineEngineType.eosb,
                caseId: CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(
                  result.calculatedAt,
                ),
                locale: locale,
                eosbIncludeSettlement: result.comparison != null,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _section(
    String locale,
    String titleKey,
    List<String> items,
    Color color,
  ) {
    if (items.isEmpty) return [];
    return [
      const SizedBox(height: AppSpacing.lg),
      Text(EosbStrings.t(titleKey, locale), style: AppTypography.title),
      const SizedBox(height: AppSpacing.sm),
      ...items.map(
        (item) => GlassCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: color,
          glowIntensity: 0.08,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(item, style: AppTypography.bodySmall)),
            ],
          ),
        ),
      ),
    ];
  }
}
