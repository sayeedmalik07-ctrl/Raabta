import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_models.dart';
import 'package:raabta/features/contract_scam_patterns/l10n/contract_scam_pattern_strings.dart';
import 'package:raabta/features/contract_scam_patterns/presentation/contract_scam_pattern_navigation.dart';

/// Phase 33 — scam-pattern findings (deterministic), evidence-row style.
class ContractScamPatternChecksSection extends StatelessWidget {
  const ContractScamPatternChecksSection({
    super.key,
    required this.locale,
    required this.result,
    this.compact = false,
  });

  final String locale;
  final ContractScamPatternResult result;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (result.scannedCharacterCount < 20) return const SizedBox.shrink();

    return GlassCard(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ContractScamPatternStrings.t('cop_section_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.warning),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ContractScamPatternStrings.t('cop_section_sub', locale),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!result.hasFindings)
            Text(
              ContractScamPatternStrings.t('cop_no_patterns', locale),
              style: AppTypography.bodySmall,
            )
          else
            ...result.findings.map(
              (f) => ContractScamPatternFindingRow(
                finding: f,
                locale: locale,
              ),
            ),
        ],
      ),
    );
  }
}

class ContractScamPatternFindingRow extends StatelessWidget {
  const ContractScamPatternFindingRow({
    super.key,
    required this.finding,
    required this.locale,
  });

  final ContractScamPatternFinding finding;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final category =
        ContractScamPatternStrings.t(finding.categoryKey, locale);
    final body = ContractScamPatternStrings.format(
      finding.wordingKey,
      locale,
      finding.params,
    );
    final source =
        ContractScamPatternStrings.t(finding.sourceLabelKey, locale);
    final nextLabel = _nextStepLabel(finding.nextStep, locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () =>
            ContractScamPatternNavigation.openNextStep(context, finding.nextStep),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_outlined,
                  size: 18, color: AppColors.chipLease),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body, style: AppTypography.bodySmall),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _SourceChip(label: category),
                        _SourceChip(label: source),
                        if (finding.sourceDateIso != null)
                          Text(
                            finding.sourceDateIso!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ContractScamPatternStrings.t('cop_next_step', locale)}: $nextLabel',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.purpleGlow,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _nextStepLabel(ContractScamPatternNextStep step, String locale) {
    final key = switch (step) {
      ContractScamPatternNextStep.paymentCheck => 'cop_next_payment_check',
      ContractScamPatternNextStep.inCallAssistant => 'cop_next_in_call',
      ContractScamPatternNextStep.officialDirectory => 'cop_next_directory',
      ContractScamPatternNextStep.beforeYouSign => 'cop_next_bys',
      ContractScamPatternNextStep.contractAnalyzer => 'cop_next_contract',
    };
    return ContractScamPatternStrings.t(key, locale);
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.glassBorder.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
