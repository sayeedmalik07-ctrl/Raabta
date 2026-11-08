import 'package:scam_shield_core/features/scam_shield/data/scam_signal_weights_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_authority_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_community_correlator.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_signal_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_social_engineering_scorer.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_stop_signal_engine.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_transaction_anomaly_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_transaction_anomaly_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_trust_label.dart';

class ScamScanRiskAnalysis {
  const ScamScanRiskAnalysis({
    required this.signals,
    required this.weightedScore,
    required this.stop,
    required this.socialScore,
    required this.trustLabel,
    required this.attackStage,
    required this.recommendedActionKeys,
    required this.authorityMatch,
    required this.transactionAnomalies,
    required this.communityCorrelation,
  });

  final Set<ScamRiskSignal> signals;
  final double weightedScore;
  final ScamStopSignalResult stop;
  final ScamSocialEngineeringScore socialScore;
  final ScamTrustLabel trustLabel;
  final ScamAttackStage attackStage;
  final List<String> recommendedActionKeys;
  final ScamAuthorityMatchResult authorityMatch;
  final ScamTransactionAnomalyResult transactionAnomalies;
  final ScamCommunityCorrelationResult communityCorrelation;
}

/// Phase 2+4+6 deterministic scan risk pipeline.
abstract final class ScamScanRiskEngine {
  static ScamScanRiskAnalysis analyze({
    required String text,
    List<String> legacyFlags = const [],
    List<ScamShieldUrlFinding> urlFindings = const [],
  }) {
    final detected = ScamSignalDetector.detect(text);
    var signals = ScamSignalDetector.mergeWithLegacyFlags(detected, legacyFlags);

    var weightedScore = 0.0;
    for (final signal in signals) {
      weightedScore += ScamSignalWeightsConfig.weightFor(signal);
    }

    final stop = ScamStopSignalEngine.evaluate(signals);
    final social = ScamSocialEngineeringScorer.score(signals);
    final authority = ScamAuthorityMatcher.match(
      text: text,
      urlFindings: urlFindings,
      signals: signals,
    );
    final transactions = ScamTransactionAnomalyDetector.analyze(text);
    final community = ScamCommunityCorrelator.analyze(text);
    if (transactions.isHighConcern) {
      signals = {...signals, ScamRiskSignal.paymentRequest};
    }
    final trust = ScamTrustLabelResolver.resolve(
      stop: stop,
      social: social,
      signals: signals,
      authority: authority,
    );
    final stage = ScamSignalStageMapper.stageFromSignals(signals);

    return ScamScanRiskAnalysis(
      signals: signals,
      weightedScore: weightedScore,
      stop: stop,
      socialScore: social,
      trustLabel: trust,
      attackStage: stage,
      authorityMatch: authority,
      transactionAnomalies: transactions,
      communityCorrelation: community,
      recommendedActionKeys: _actionsFor(
        trust,
        stop,
        authority,
        transactions,
        community,
      ),
    );
  }

  static List<String> _actionsFor(
    ScamTrustLabel trust,
    ScamStopSignalResult stop,
    ScamAuthorityMatchResult authority,
    ScamTransactionAnomalyResult transactions,
    ScamCommunityCorrelationResult community,
  ) {
    if (stop.triggered) {
      return const [
        'ss_action_stop_contact',
        'ss_action_do_not_share',
        'ss_action_verify_official',
      ];
    }
    if (authority.domainMismatch) {
      return const [
        'ss_action_stop_contact',
        'ss_auth_action_mismatch',
        'ss_action_verify_official',
      ];
    }
    if (transactions.isHighConcern) {
      return const [
        'ss_tx_action_contact_bank',
        'ss_action_preserve_evidence',
        'ss_action_verify_official',
      ];
    }
    if (community.isStrongMatch) {
      return const [
        'ss_community_action_pause',
        'ss_community_action_report',
        'ss_action_verify_official',
      ];
    }
    return switch (trust) {
      ScamTrustLabel.verified => ['ss_trust_verified_framing'],
      ScamTrustLabel.likelySafe => ['ss_action_verify_if_unsure'],
      ScamTrustLabel.needsVerification => [
          'ss_action_pause',
          'ss_action_verify_official',
        ],
      ScamTrustLabel.highRisk => [
          'ss_action_stop_contact',
          'ss_action_verify_official',
        ],
      ScamTrustLabel.critical => [
          'ss_action_stop_contact',
          'ss_action_do_not_share',
          'ss_action_verify_official',
        ],
    };
  }
}
