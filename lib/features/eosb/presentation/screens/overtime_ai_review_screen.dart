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
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_ai_service.dart';

class OvertimeAiReviewScreen extends ConsumerStatefulWidget {
  const OvertimeAiReviewScreen({super.key});

  @override
  ConsumerState<OvertimeAiReviewScreen> createState() =>
      _OvertimeAiReviewScreenState();
}

class _OvertimeAiReviewScreenState extends ConsumerState<OvertimeAiReviewScreen> {
  int _refreshTick = 0;

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final result = ref.watch(overtimeTruthProvider).result;
    // ignore: unused_local_variable
    final _ = _refreshTick;
    const request = OvertimeAiReviewRequest();
    final review = ref.watch(overtimeAiReviewProvider(request));

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (result == null || review == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('ot_ai_review', locale),
            body: GlassEmptyState(
              icon: Icons.auto_awesome,
              title: EosbStrings.t('ot_empty_title', locale),
              description: EosbStrings.t('ot_empty_desc', locale),
              actionLabel: EosbStrings.t('ot_calendar_mode', locale),
              onAction: () => context.push('/eosb/overtime/calendar'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: EosbStrings.t('ot_ai_review', locale),
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
                glowColor: AppColors.sharePurple,
                glowIntensity: 0.18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EosbStrings.t('ot_ai_summary', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(review.summary, style: AppTypography.body),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${EosbStrings.t('ot_confidence', locale)}: '
                      '${(review.confidence * 100).toStringAsFixed(0)}%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: EosbStrings.t('ot_ai_calc_explain', locale),
                body: review.calculationExplanation,
              ),
              _ListSection(
                title: EosbStrings.t('ot_ai_missing', locale),
                items: review.missingPayments,
              ),
              _ListSection(
                title: EosbStrings.t('ot_ai_errors', locale),
                items: review.potentialErrors,
              ),
              _ListSection(
                title: EosbStrings.t('ot_ai_questions', locale),
                items: review.questionsForEmployer,
              ),
              _ListSection(
                title: EosbStrings.t('ot_ai_tips', locale),
                items: review.payrollTips,
              ),
              _ListSection(
                title: EosbStrings.t('ot_ai_next', locale),
                items: review.nextSteps,
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_ai_refresh', locale),
                expand: true,
                accentColor: AppColors.accentGold,
                icon: Icons.refresh,
                onPressed: () => setState(() => _refreshTick++),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(item, style: AppTypography.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
