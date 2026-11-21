import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hub_primary_button.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/domain/services/overtime_rounding_pattern_analyzer.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_locale_load_error_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_salary_claude_consent_feedback.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_rounding_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_ai_service.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/providers/auth_providers.dart';

/// Deterministic rounding pattern detector — human-readable summary, no accusations.
class OvertimeRoundingPatternScreen extends ConsumerStatefulWidget {
  const OvertimeRoundingPatternScreen({super.key});

  @override
  ConsumerState<OvertimeRoundingPatternScreen> createState() =>
      _OvertimeRoundingPatternScreenState();
}

class _OvertimeRoundingPatternScreenState
    extends ConsumerState<OvertimeRoundingPatternScreen> {
  bool _aiLoading = false;

  Future<void> _explainPattern(String locale) async {
    final pattern = ref.read(overtimeRoundingPatternProvider);
    if (!pattern.hasEnoughData) return;

    final consent = await ref.read(eosbSalaryConsentProvider.future);
    if (!consent) {
      if (mounted) showEosbSalaryClaudeConsentSnackBar(context, locale);
      return;
    }

    ref.read(overtimeRoundingAiExplanationProvider.notifier).state = null;
    setState(() => _aiLoading = true);

    try {
      final text = await ref
          .read(overtimeAiServiceProvider)
          .explainRoundingPattern(pattern: pattern, locale: locale);
      if (mounted) {
        ref.read(overtimeRoundingAiExplanationProvider.notifier).state = text;
        setState(() => _aiLoading = false);
      }
    } on EosbSalaryClaudeConsentRequired {
      if (mounted) {
        showEosbSalaryClaudeConsentSnackBar(context, locale);
        setState(() => _aiLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _addTimelineNote(String locale) async {
    final pattern = ref.read(overtimeRoundingPatternProvider);
    final result = ref.read(overtimeTruthProvider).result;
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null || result == null || !pattern.hasEnoughData) return;

    final caseId = CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(
      result.calculatedAt,
    );
    final summary = EosbStrings.format('ot_rounding_timeline_note', locale, {
      'clockIn': pattern.clockInEmployerFavorCount.toString(),
      'total': pattern.dualShiftCount.toString(),
      'avgMin': pattern.avgTotalMinutesLostPerShift.toStringAsFixed(1),
    });

    await ref
        .read(caseTimelineServiceProvider)
        .addEntry(
          userId: uid,
          engineType: CaseTimelineEngineType.eosb,
          caseId: caseId,
          entryDate: DateTime.now(),
          entryType: CaseTimelineEntryType.note,
          title: EosbStrings.t('ot_rounding_timeline_title', locale),
          description: summary,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('ot_rounding_timeline_saved', locale)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    final presentationLocale = ref.watch(eosbPresentationLocaleProvider);
    final pattern = ref.watch(overtimeRoundingPatternProvider);
    final aiExplanation = ref.watch(overtimeRoundingAiExplanationProvider);
    final comparison = ref.watch(overtimeTruthProvider).result?.comparison;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => EosbLocaleLoadErrorScaffold(
        scaffoldTitle: EosbStrings.t('ot_rounding_title', presentationLocale),
        descriptionSubtitleKey: 'ot_subtitle',
      ),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_rounding_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                EosbStrings.t('ot_rounding_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!pattern.hasEnoughData)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EosbStrings.t('ot_rounding_need_more', locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        EosbStrings.format('ot_rounding_progress', locale, {
                          'current': pattern.dualShiftCount.toString(),
                          'required': pattern.minRequiredShifts.toString(),
                        }),
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        EosbStrings.t('ot_rounding_need_more_hint', locale),
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      EosbHubPrimaryButton(
                        label: EosbStrings.t('ot_calendar_mode', locale),
                        icon: Icons.calendar_month_outlined,
                        expand: true,
                        onPressed: () =>
                            context.push('/eosb/overtime/calendar'),
                      ),
                    ],
                  ),
                )
              else ...[
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.known,
                  text: TruthPackageCatalog.eosbOvertimeAssumptionDisplay(
                    0,
                    locale,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PatternSummaryCard(pattern: pattern, locale: locale),
                if (comparison != null &&
                    (comparison.hoursGap > 0 || comparison.isUnderpaid)) ...[
                  const SizedBox(height: AppSpacing.md),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.action,
                    text: EosbStrings.t('ot_rounding_comparison_link', locale),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: AppColors.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/eosb/overtime'),
                          child: Text(
                            EosbStrings.t('ot_employer_comparison', locale),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: _aiLoading ? null : () => _explainPattern(locale),
                  child: Text(
                    _aiLoading
                        ? '…'
                        : EosbStrings.t('ot_rounding_explain', locale),
                  ),
                ),
                if (aiExplanation != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.possible,
                    text: TruthPackageCatalog.eosbOvertimeAssumptionDisplay(
                      0,
                      locale,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.unknown,
                    text: TruthPackageCatalog.eosbOvertimeUnknownDisplay(
                      0,
                      locale,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(aiExplanation, style: AppTypography.bodySmall),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _addTimelineNote(locale),
                  child: Text(
                    EosbStrings.t('ot_rounding_add_timeline', locale),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PatternSummaryCard extends StatelessWidget {
  const _PatternSummaryCard({required this.pattern, required this.locale});

  final OvertimeRoundingPatternResult pattern;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final accent = pattern.direction == OvertimeRoundingDirection.employerFavor
        ? AppColors.accentGold
        : AppColors.cyanGlow;

    final summary = EosbStrings.format(pattern.primaryPatternKey, locale, {
      'clockInCount': pattern.clockInEmployerFavorCount.toString(),
      'clockOutCount': pattern.clockOutEmployerFavorCount.toString(),
      'total': pattern.dualShiftCount.toString(),
      'avgIn': pattern.avgClockInLossMinutes.toStringAsFixed(1),
      'avgOut': pattern.avgClockOutLossMinutes.toStringAsFixed(1),
      'avgTotal': pattern.avgTotalMinutesLostPerShift.toStringAsFixed(1),
      'qar': pattern.estimatedQarImpact.toStringAsFixed(2),
      'currency': pattern.currency,
    });

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('ot_rounding_summary_heading', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(summary, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Text(
            EosbStrings.t('ot_rounding_no_accusation', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (pattern.estimatedQarImpact > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              EosbStrings.format('ot_rounding_qar_estimate', locale, {
                'amount': pattern.estimatedQarImpact.toStringAsFixed(2),
                'currency': pattern.currency,
              }),
              style: AppTypography.bodySmall.copyWith(color: accent),
            ),
          ],
        ],
      ),
    );
  }
}
