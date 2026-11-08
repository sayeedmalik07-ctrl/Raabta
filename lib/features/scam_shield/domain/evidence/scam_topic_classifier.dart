import 'package:raabta/features/scam_shield/domain/evidence/event_ticket_detector.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_bridge_topic.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_correlator.dart';
import 'package:raabta/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Maps Phase 6 community archetypes, user content type, and local flags to
/// at most one [ScamBridgeTopic]. Pure — no network, no AI.
abstract final class ScamTopicClassifier {
  static ScamBridgeTopic classify({
    required String text,
    required ScamShieldContentType contentType,
    required List<String> localFlags,
    required ScamScanRiskAnalysis scanAnalysis,
  }) {
    final community = scanAnalysis.communityCorrelation;
    final topPattern = community.strongest?.patternId;
    final signals = scanAnalysis.signals;
    final lower = text.toLowerCase();

    if (_matchesRecoveryOffer(lower, signals)) {
      return ScamBridgeTopic.recoveryOffer;
    }

    if (EventTicketDetector.detect(text)) {
      return ScamBridgeTopic.eventTickets;
    }

    if (contentType == ScamShieldContentType.investmentOffer ||
        topPattern == 'investment_guaranteed') {
      return ScamBridgeTopic.investment;
    }

    if (localFlags.contains('ss_flag_upfront_fee') ||
        topPattern == 'job_visa_fee') {
      return ScamBridgeTopic.recruitmentFee;
    }

    if (contentType == ScamShieldContentType.jobOffer ||
        topPattern == 'job_visa_fee') {
      return ScamBridgeTopic.jobOffer;
    }

    if (contentType == ScamShieldContentType.rentalOffer ||
        topPattern == 'rental_deposit_scam') {
      return ScamBridgeTopic.housingDeposit;
    }

    if (_matchesVisaAgent(lower, topPattern)) {
      return ScamBridgeTopic.visaOrSponsorshipAgent;
    }

    if (_matchesSettlementOrSalary(lower)) {
      return ScamBridgeTopic.finalSettlementOrSalary;
    }

    if (_matchesInsuranceCall(lower, topPattern)) {
      return ScamBridgeTopic.insuranceCall;
    }

    if (_matchesRemittanceEmergency(lower, signals)) {
      return ScamBridgeTopic.remittanceEmergency;
    }

    if (topPattern == 'fake_moi_fine' ||
        topPattern == 'delivery_customs_fee' ||
        _matchesGovernmentFine(lower, signals)) {
      return ScamBridgeTopic.governmentFineOrFee;
    }

    return _topicFromContentTypeOnly(contentType);
  }

  /// Explicit user category when pattern checks found nothing.
  static ScamBridgeTopic _topicFromContentTypeOnly(
    ScamShieldContentType contentType,
  ) {
    return switch (contentType) {
      ScamShieldContentType.jobOffer => ScamBridgeTopic.jobOffer,
      ScamShieldContentType.rentalOffer => ScamBridgeTopic.housingDeposit,
      ScamShieldContentType.investmentOffer => ScamBridgeTopic.investment,
      _ => ScamBridgeTopic.none,
    };
  }

  static bool _matchesRecoveryOffer(String lower, Set<ScamRiskSignal> signals) {
    const phrases = [
      'recovery agent',
      'asset recovery',
      'get your money back',
      'refund processing fee',
      'chargeback service',
      'recovery fee',
      'استرداد',
      'وكيل استرداد',
    ];
    if (phrases.any((p) => ScamMultilingualMatcher.containsPattern(lower, p))) {
      return true;
    }
    return signals.contains(ScamRiskSignal.financialImpersonation) &&
        (lower.contains('recovery') || lower.contains('refund fee'));
  }

  static bool _matchesVisaAgent(String lower, String? topPattern) {
    if (topPattern == 'job_visa_fee' && lower.contains('agent')) return true;
    const terms = [
      'visa agent',
      'sponsorship transfer',
      'change sponsor',
      'noc for transfer',
      'runaway',
      'وكيل تأشيرة',
      'نقل كفالة',
    ];
    return terms.any((t) => ScamMultilingualMatcher.containsPattern(lower, t));
  }

  static bool _matchesSettlementOrSalary(String lower) {
    const terms = [
      'final settlement',
      'end of service',
      'eosb',
      'gratuity',
      'overtime not paid',
      'salary delay',
      'مكافأة',
      'نهاية الخدمة',
    ];
    return terms.any((t) => ScamMultilingualMatcher.containsPattern(lower, t));
  }

  static bool _matchesInsuranceCall(String lower, String? topPattern) {
    if (topPattern == 'telecom_sim_block') return false;
    const terms = [
      'health insurance',
      'insurance renewal',
      'policy expired',
      'medical card',
      'seha',
      'تأمين',
      'بطاقة صحية',
    ];
    return terms.any((t) => ScamMultilingualMatcher.containsPattern(lower, t));
  }

  static bool _matchesRemittanceEmergency(String lower, Set<ScamRiskSignal> signals) {
    const emergency = [
      'send money urgently',
      'family emergency',
      'hospital bill',
      'stuck at airport',
      'طوارئ',
      'حول فلوس',
    ];
    if (emergency.any((t) => ScamMultilingualMatcher.containsPattern(lower, t))) {
      return true;
    }
    return signals.contains(ScamRiskSignal.transferRequest) &&
        (lower.contains('relative') || lower.contains('cousin'));
  }

  static bool _matchesGovernmentFine(String lower, Set<ScamRiskSignal> signals) {
    if (!signals.contains(ScamRiskSignal.authorityImpersonation)) return false;
    return lower.contains('fine') ||
        lower.contains('غرامة') ||
        lower.contains('customs') ||
        lower.contains('جمارك');
  }
}
