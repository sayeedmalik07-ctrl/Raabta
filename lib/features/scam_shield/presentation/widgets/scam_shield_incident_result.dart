import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_incident_label_keys.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_evidence_panel.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';

class ScamShieldIncidentResultView extends StatelessWidget {
  const ScamShieldIncidentResultView({
    super.key,
    required this.result,
    required this.locale,
    this.onSaveEvidence,
  });

  final ScamIncidentAssessmentResult result;
  final String locale;
  final Future<ScamEvidenceRecord> Function()? onSaveEvidence;

  @override
  Widget build(BuildContext context) {
    final levelColor = scamShieldRiskColor(result.displaySeverity);

    return ScamShieldEntranceReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScamShieldVerdictCard(
            overline: ScamShieldStrings.t('ss_ir_priority', locale),
            headline: ScamShieldStrings.t(result.responsePriority.labelKey, locale),
            accentColor: levelColor,
            subtitle: ScamShieldStrings.t(result.responseLevel.labelKey, locale),
            leadingIcon: Icons.emergency_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_chain_confidence_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ScamShieldStrings.t(result.confidenceBand.labelKey, locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.chipLease,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ScamShieldStrings.t('ss_evidence_reported', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_ir_stage', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.stageSummaryKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '• ${ScamShieldStrings.t(key, locale)}',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
        if (result.chainNarrative != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_ir_chain', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            result.chainNarrative!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.chipLease,
            ),
          ),
        ],
        if (showsSecondaryScamPanel(result)) ...[
          const SizedBox(height: AppSpacing.md),
          _SecondaryScamPanel(locale: locale),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_safe_verify_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.safeVerificationKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 18, color: levelColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ScamShieldStrings.t(key, locale),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_ir_checklist', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.checklistActionKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: levelColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ScamShieldStrings.t(key, locale),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_ir_no_proof', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (result.responseLevel.rank >=
            ScamIncidentResponseLevel.level5.rank) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.push('/scam-shield/report-ready'),
            icon: const Icon(Icons.folder_shared_outlined),
            label: Text(
              ScamShieldStrings.t('ss_rp_open_from_incident', locale),
            ),
          ),
        ],
        if (onSaveEvidence != null &&
            result.responseLevel.rank >=
                ScamIncidentResponseLevel.level4.rank) ...[
          const SizedBox(height: AppSpacing.lg),
          ScamShieldEvidencePanel(
            locale: locale,
            responseLevel: result.responseLevel,
            onSave: onSaveEvidence!,
          ),
        ],
      ],
      ),
    );
  }
}

class _SecondaryScamPanel extends StatelessWidget {
  const _SecondaryScamPanel({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    const keys = [
      'ss_secondary_scam_body',
      'ss_secondary_scam_no_trust',
      'ss_secondary_scam_no_money',
      'ss_secondary_scam_no_otp',
      'ss_secondary_scam_no_remote',
      'ss_secondary_scam_no_contact',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBright.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.errorBright.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldStrings.t('ss_secondary_scam_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.errorBright,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final key in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• ${ScamShieldStrings.t(key, locale)}',
                style: AppTypography.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
