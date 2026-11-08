import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_transaction_anomaly_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_trust_label.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_location_reporting.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_pattern_area_report_prompt.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_community_correlation_panel.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_evidence_panel.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_stop_banner.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_evidence_card.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_trust_banner.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';

String scamShieldFlagLabel(String key, String locale) {
  if (key.startsWith('ss_flag_') ||
      key.startsWith('ss_requested_') ||
      key.startsWith('ss_signal_')) {
    return ScamShieldStrings.t(key, locale);
  }
  return key;
}

class ScamShieldAssessmentResultsView extends ConsumerWidget {
  const ScamShieldAssessmentResultsView({
    super.key,
    required this.result,
    required this.locale,
    required this.maskedInput,
    this.sourceText = '',
    this.senderType = ScamMessageSenderType.notSure,
    this.flagLabel = scamShieldFlagLabel,
    this.onLegitimateTap,
  });

  final ScamShieldAssessmentResult result;
  final String locale;
  final String maskedInput;
  final String sourceText;
  final ScamMessageSenderType senderType;
  final String Function(String key, String locale) flagLabel;
  final VoidCallback? onLegitimateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = result.scanAnalysis;
    final explainSignals = analysis.signals.map((s) => s.labelKey).toList();
    final showGuidance =
        result.overallRisk != ScamShieldRiskLevel.low || analysis.stop.triggered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (analysis.stop.triggered) ...[
          ScamShieldStopBanner(stop: analysis.stop, locale: locale),
          const SizedBox(height: AppSpacing.md),
        ],
        if (sourceText.isNotEmpty) ...[
          ScamShieldEvidenceCard(
            sourceText: sourceText,
            result: result,
            locale: locale,
            maskedInput: maskedInput,
            senderType: senderType,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          ScamShieldTrustBanner(analysis: analysis, locale: locale),
        ],
        if (result.redFlags.contains('ss_flag_sideload_app')) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_sideload_banner', locale),
            style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
          ),
        ],
        if (_showsSimSwapLink(analysis)) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.push('/scam-shield/sim-swap'),
            icon: const Icon(Icons.sim_card_alert_outlined),
            label: Text(ScamShieldStrings.t('ss_sim_scan_link', locale)),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: scamShieldAccent,
          glowIntensity: 0.04,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.aiCapReached)
                Text(
                  ScamShieldStrings.t('ss_ai_cap_reached', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.warning),
                )
              else if (result.usedAi) ...[
                Text(
                  ScamShieldStrings.t('ss_ai_used', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('ss_ai_privacy_note', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ] else
                Text(
                  ScamShieldStrings.t('ss_local_only', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              if (result.aiSupplementary?.differsFromDeterministic == true) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ScamShieldStrings.t('ss_ai_differs', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.warning),
                ),
              ],
            ],
          ),
        ),
        if (result.aiSupplementary != null &&
            result.aiSupplementary!.assessment.redFlags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_ai_supplementary', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...result.aiSupplementary!.assessment.redFlags.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $f', style: AppTypography.bodySmall),
            ),
          ),
        ],
        if (explainSignals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_why_heading', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...explainSignals.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flagLabel(key, locale),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ScamShieldStrings.t('ss_ir_no_proof', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (analysis.recommendedActionKeys.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_recommended_actions', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...analysis.recommendedActionKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• ${ScamShieldStrings.t(key, locale)}',
                style: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
        if (analysis.transactionAnomalies.hasAnomalies) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_tx_anomalies_heading', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...analysis.transactionAnomalies.anomalies.map(
            (anomaly) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _transactionAnomalyLabel(anomaly, locale),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (analysis.communityCorrelation.hasMatches) ...[
          const SizedBox(height: AppSpacing.md),
          ScamShieldCommunityCorrelationPanel(
            correlation: analysis.communityCorrelation,
            locale: locale,
          ),
          if (ScamCommunityLocationReporting.firstLocationRelevantMatch(
                analysis.communityCorrelation,
              ) !=
              null) ...[
            const SizedBox(height: AppSpacing.md),
            ScamPatternAreaReportPrompt(
              archetypeId: ScamCommunityLocationReporting
                  .firstLocationRelevantMatch(analysis.communityCorrelation)!
                  .patternId,
              locale: locale,
            ),
          ],
        ],
        if (_showsEvidencePanel(analysis)) ...[
          const SizedBox(height: AppSpacing.lg),
          ScamShieldEvidencePanel(
            locale: locale,
            onSave: () => ref.read(scamEvidenceLockerServiceProvider).saveFromAssessment(
                  result: result,
                  maskedInput: maskedInput,
                ),
          ),
        ],
        if (onLegitimateTap != null) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLegitimateTap,
              child: Text(
                ScamAnonymousSignalStrings.t('ss_signal_legit_tap', locale),
              ),
            ),
          ),
        ],
        if (result.redFlags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_red_flags', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...result.redFlags.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flagLabel(f, locale),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (result.requestedInfo.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_requested', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...result.requestedInfo.map(
            (k) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• ${flagLabel(k, locale)}',
                  style: AppTypography.bodySmall),
            ),
          ),
        ],
        if (result.urlFindings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_url_checks', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...result.urlFindings.map((u) {
            final official = u.isKnownLegitimate
                ? OfficialDirectory.lookupByDomain(u.domain)
                : null;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.domain, style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  Text(
                    official != null
                        ? ScamShieldStrings.t(
                            'ss_url_official_domain_match',
                            locale,
                          ).replaceAll(
                            '{entity}',
                            official.displayName(locale),
                          )
                        : ScamShieldStrings.t('ss_url_not_allowlisted', locale),
                    style: AppTypography.caption,
                  ),
                  if (official != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ScamShieldStrings.t('ss_url_not_guarantee', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (u.flags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ...u.flags.map(
                      (flag) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${flagLabel(flag, locale)}',
                          style: AppTypography.caption.copyWith(
                            color: flag == 'ss_flag_web_risk_threat'
                                ? AppColors.chipLease
                                : AppColors.textOnGlassMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (u.webRiskChecked && u.webRiskUnavailable) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ScamShieldStrings.t('ss_url_web_risk_unavailable', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          ScamShieldStrings.t('ss_verify_heading', locale),
          style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (showGuidance)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              ScamShieldStrings.t('ss_guidance_medium_high', locale),
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        Text(
          ScamShieldStrings.t('ss_guidance_always', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.verificationChannelKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined,
                    size: 16, color: AppColors.successBright),
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
      ],
    );
  }

  static bool _showsSimSwapLink(ScamScanRiskAnalysis analysis) {
    const simSignals = {
      ScamRiskSignal.simChange,
      ScamRiskSignal.esimChange,
      ScamRiskSignal.numberPortRequest,
      ScamRiskSignal.telecomImpersonation,
    };
    return analysis.attackStage == ScamAttackStage.simSwapRisk ||
        analysis.signals.any(simSignals.contains);
  }

  static bool _showsEvidencePanel(ScamScanRiskAnalysis analysis) {
    return analysis.stop.triggered ||
        analysis.trustLabel == ScamTrustLabel.highRisk ||
        analysis.trustLabel == ScamTrustLabel.critical ||
        analysis.transactionAnomalies.hasAnomalies;
  }

  static String _transactionAnomalyLabel(
    ScamTransactionAnomaly anomaly,
    String locale,
  ) {
    if (anomaly.amountQar != null) {
      return ScamShieldStrings.format(
        anomaly.kind.labelKey,
        locale,
        {'amount': anomaly.amountQar!.toStringAsFixed(0)},
      );
    }
    return ScamShieldStrings.t(anomaly.kind.labelKey, locale);
  }
}
