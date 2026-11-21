import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/eosb/data/eosb_labour_dispute_escalation_catalog.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Informational dispute escalation path — MoL/ADLSA → LDRC → WSIF if unpaid.
class EosbLabourDisputeEscalationSection extends StatelessWidget {
  const EosbLabourDisputeEscalationSection({super.key, required this.locale});

  final String locale;

  static const _wsifUrl = 'https://wsif.gov.qa';

  Future<void> _openWsifSite() async {
    final uri = Uri.parse(_wsifUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.accentGold,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('eosb_dispute_escalation_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.accentGold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            EosbStrings.t('eosb_dispute_escalation_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          ...EosbLabourDisputeEscalationCatalog.all.asMap().entries.map(
                (entry) => _StepRow(
                  stepNumber: entry.key + 1,
                  step: entry.value,
                  locale: locale,
                  onOpenWsif: _openWsifSite,
                ),
              ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            EosbStrings.t('eosb_dispute_escalation_disclaimer', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.stepNumber,
    required this.step,
    required this.locale,
    required this.onOpenWsif,
  });

  final int stepNumber;
  final EosbLabourDisputeEscalationStepDef step;
  final String locale;
  final VoidCallback onOpenWsif;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.accentGold.withValues(alpha: 0.2),
                child: Text(
                  '$stepNumber',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EosbStrings.t(step.titleKey, locale),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      EosbStrings.t(step.descriptionKey, locale),
                      style: AppTypography.bodySmall,
                    ),
                    if (step.supplementKey != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        EosbStrings.t(step.supplementKey!, locale),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (step.isWsifStep) ...[
            const SizedBox(height: AppSpacing.sm),
            TruthConfidenceBanner(
              locale: locale,
              state: TruthConfidenceState.known,
              text: EosbStrings.t('eosb_dispute_step4_known', locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            TruthConfidenceBanner(
              locale: locale,
              state: TruthConfidenceState.unknown,
              text: EosbStrings.t('eosb_dispute_step4_unknown', locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            TruthConfidenceBanner(
              locale: locale,
              state: TruthConfidenceState.action,
              text: EosbStrings.t('eosb_dispute_step4_action', locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton.icon(
              onPressed: onOpenWsif,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(EosbStrings.t('eosb_dispute_step4_wsif_link', locale)),
            ),
          ],
        ],
      ),
    );
  }
}
