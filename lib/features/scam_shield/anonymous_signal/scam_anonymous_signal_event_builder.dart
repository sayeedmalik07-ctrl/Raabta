import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_schema.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

abstract final class ScamAnonymousSignalEventBuilder {
  static String utcDayKey(DateTime now) {
    final u = now.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}';
  }

  static ScamAnonymousSignalEvent fromAssessment({
    required ScamShieldAssessmentResult result,
    required String sourceTextForLocalClassification,
    required List<String> evidenceKindNames,
    required String locale,
    required ScamMessageSenderType senderType,
    ScamAnonymousSignalFeedback feedback = ScamAnonymousSignalFeedback.none,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final archetypes = _topArchetypes(result);
    final kinds = evidenceKindNames
        .where((k) => k.isNotEmpty)
        .take(ScamAnonymousSignalSchema.maxEvidenceKinds)
        .toList();

    return ScamAnonymousSignalEvent(
      dayUtc: utcDayKey(clock),
      channel: _channel(result, senderType),
      archetypes: archetypes,
      evidenceKinds: kinds,
      riskBand: _riskBand(result.overallRisk),
      claimedEntityCategory: _claimedCategory(
        sourceTextForLocalClassification,
        locale,
      ),
      uiLocale: locale,
      feedback: feedback,
    );
  }

  static List<String> _topArchetypes(ScamShieldAssessmentResult result) {
    final matches = result.scanAnalysis.communityCorrelation.matches;
    final sorted = [...matches]..sort((a, b) => b.score.compareTo(a.score));
    return sorted
        .map((m) => m.patternId)
        .where(ScamAnonymousSignalSchema.allowedArchetypes.contains)
        .take(ScamAnonymousSignalSchema.maxArchetypes)
        .toList();
  }

  static ScamAnonymousSignalRiskBand _riskBand(ScamShieldRiskLevel level) {
    return switch (level) {
      ScamShieldRiskLevel.low => ScamAnonymousSignalRiskBand.none,
      ScamShieldRiskLevel.medium => ScamAnonymousSignalRiskBand.medium,
      ScamShieldRiskLevel.high => ScamAnonymousSignalRiskBand.high,
    };
  }

  static ScamAnonymousSignalChannel _channel(
    ScamShieldAssessmentResult result,
    ScamMessageSenderType senderType,
  ) {
    final fromSender = switch (senderType) {
      ScamMessageSenderType.email => ScamAnonymousSignalChannel.email,
      ScamMessageSenderType.whatsAppTelegramSocial =>
        ScamAnonymousSignalChannel.whatsapp,
      ScamMessageSenderType.localMobile => ScamAnonymousSignalChannel.sms,
      ScamMessageSenderType.internationalNumber =>
        ScamAnonymousSignalChannel.call,
      ScamMessageSenderType.senderNameOrShortCode =>
        ScamAnonymousSignalChannel.sms,
      ScamMessageSenderType.notSure => null,
    };
    if (fromSender != null) return fromSender;

    return switch (result.contentType) {
      ScamShieldContentType.whatsAppSms => ScamAnonymousSignalChannel.whatsapp,
      ScamShieldContentType.email => ScamAnonymousSignalChannel.email,
      ScamShieldContentType.websiteUrl => ScamAnonymousSignalChannel.other,
      ScamShieldContentType.paymentRequest => ScamAnonymousSignalChannel.other,
      ScamShieldContentType.jobOffer => ScamAnonymousSignalChannel.classifiedsChat,
      ScamShieldContentType.rentalOffer => ScamAnonymousSignalChannel.classifiedsChat,
      ScamShieldContentType.investmentOffer => ScamAnonymousSignalChannel.social,
    };
  }

  static ScamAnonymousSignalClaimedCategory _claimedCategory(
    String text,
    String locale,
  ) {
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    if (claim.matches.isEmpty) {
      return ScamAnonymousSignalClaimedCategory.none;
    }
    final entry = OfficialDirectory.lookupById(claim.matches.first);
    if (entry == null) return ScamAnonymousSignalClaimedCategory.none;
    return switch (entry.category) {
      OfficialDirectoryCategory.government =>
        ScamAnonymousSignalClaimedCategory.government,
      OfficialDirectoryCategory.banking =>
        ScamAnonymousSignalClaimedCategory.banking,
      OfficialDirectoryCategory.telecom =>
        ScamAnonymousSignalClaimedCategory.telecom,
      OfficialDirectoryCategory.airline =>
        ScamAnonymousSignalClaimedCategory.airline,
      OfficialDirectoryCategory.utilities =>
        ScamAnonymousSignalClaimedCategory.utilities,
      OfficialDirectoryCategory.health =>
        ScamAnonymousSignalClaimedCategory.health,
      OfficialDirectoryCategory.other =>
        ScamAnonymousSignalClaimedCategory.other,
    };
  }
}
