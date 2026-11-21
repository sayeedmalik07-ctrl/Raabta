import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_scenario.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_already_lost_money_button.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class FamilyVerificationScenarioScreen extends ConsumerStatefulWidget {
  const FamilyVerificationScenarioScreen({super.key});

  @override
  ConsumerState<FamilyVerificationScenarioScreen> createState() =>
      _FamilyVerificationScenarioScreenState();
}

class _FamilyVerificationScenarioScreenState
    extends ConsumerState<FamilyVerificationScenarioScreen> {
  FamilyScenarioNodeId _node = FamilyScenarioNodeId.start;
  String? _feedbackKey;

  static final _teal = AppColors.tealFamilyMain;

  static const _totalScenarioSteps = 4;

  int _stepIndex(FamilyScenarioNodeId id) {
    return switch (id) {
      FamilyScenarioNodeId.start => 1,
      FamilyScenarioNodeId.afterHangUp => 2,
      FamilyScenarioNodeId.afterCallBack => 3,
      FamilyScenarioNodeId.complete => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final step = FamilyVerificationScenario.step(_node);
    final stepNum = _stepIndex(_node);
    final stepLabel = FamilyVerificationKitStrings.scenarioProgressLine(
      locale,
      stepNum,
      _totalScenarioSteps,
    );

    return HubSubscreenScaffold(
      title: FamilyVerificationKitStrings.t('ss_fvk_scenario_title', locale),
      subtitle: FamilyVerificationKitStrings.t(
        'ss_fvk_scenario_subtitle',
        locale,
      ),
      onBack: () => context.pop(),
      body: ListView(
        padding: moneyHubScreenPadding,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              FamilyVerificationKitStrings.t(
                'ss_fvk_scenario_section_situation',
                locale,
              ),
              style: AppTypography.subtitle.copyWith(
                color: _teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            glowColor: _teal,
            glowIntensity: 0.07,
            borderRadius: AppSpacing.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  stepLabel,
                  style: AppTypography.caption.copyWith(
                    color: _teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  child: LinearProgressIndicator(
                    value: stepNum / _totalScenarioSteps,
                    minHeight: 6,
                    backgroundColor: _teal.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(_teal),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  FamilyVerificationKitStrings.t(step.narrativeKey, locale),
                  style: AppTypography.body.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          if (_feedbackKey != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                FamilyVerificationKitStrings.t(
                  'ss_fvk_scenario_section_feedback',
                  locale,
                ),
                style: AppTypography.subtitle.copyWith(
                  color: _teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _feedbackPanel(locale, step),
          ],
          if (step.choices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                FamilyVerificationKitStrings.t(
                  'ss_fvk_scenario_section_choices',
                  locale,
                ),
                style: AppTypography.subtitle.copyWith(
                  color: _teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final choice in step.choices)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () {
                    setState(() {
                      _feedbackKey =
                          FamilyVerificationScenario.feedbackKey(choice);
                      if (choice.nextNodeId != null) {
                        _node = choice.nextNodeId!;
                      }
                    });
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  glowColor: _teal,
                  glowIntensity: 0.05,
                  borderRadius: AppSpacing.radiusMd,
                  child: SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        FamilyVerificationKitStrings.t(choice.labelKey, locale),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
          if (step.isSuccess) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                setState(() {
                  _node = FamilyScenarioNodeId.start;
                  _feedbackKey = null;
                });
              },
              child: Text(
                FamilyVerificationKitStrings.t(
                  'ss_fvk_scenario_restart',
                  locale,
                ),
                style: TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (_node == FamilyScenarioNodeId.afterCallBack ||
              _node == FamilyScenarioNodeId.afterHangUp) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                FamilyVerificationKitStrings.t(
                  'ss_fvk_scenario_section_emergency',
                  locale,
                ),
                style: AppTypography.subtitle.copyWith(
                  color: _teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              glowColor: AppColors.warning.withValues(alpha: 0.25),
              glowIntensity: 0.04,
              borderRadius: AppSpacing.radiusMd,
              child: ScamAlreadyLostMoneyTextButton(locale: locale),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feedbackPanel(String locale, FamilyScenarioStep step) {
    final isSuccess = step.isSuccess;
    final accent = isSuccess ? AppColors.success : AppColors.warning;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: accent,
      glowIntensity: 0.1,
      borderRadius: AppSpacing.radiusMd,
      backgroundColor: accent.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: accent,
            size: AppSpacing.iconLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              FamilyVerificationKitStrings.t(_feedbackKey!, locale),
              style: AppTypography.bodySmall.copyWith(
                color: accent,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
