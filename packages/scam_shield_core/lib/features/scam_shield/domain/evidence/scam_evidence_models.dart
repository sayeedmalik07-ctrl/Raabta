import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';

enum ScamEvidenceKind {
  lookalikeDomain,
  exactOfficialDomain,
  claimedEntity,
  advisoryMatch,
  senderChannelMismatch,
  moneyMuleRecruitment,
  paymentRedFlag,
  sideloadApp,
  platformHop,
  domainAgeConcern,
  domainAgeInfo,
  shortLinkDestination,
  redirectChainLong,
  recoveryOffer,
  payToEarnTask,
  fakeFineToll,
  oneRingCallback,
  investmentOfferSign,
  phoneNumberConcern,
  personalContextMismatch,
  eventTicketScam,
  outdatedBrandReference,
}

enum ScamEvidenceDirection { concern, informational }

class ScamEvidence {
  const ScamEvidence({
    required this.kind,
    required this.priority,
    required this.textKey,
    required this.sourceLabel,
    this.params = const {},
    this.sourceDate,
    this.sourceUrl,
    this.entityId,
    this.advisoryId,
    this.direction = ScamEvidenceDirection.concern,
  });

  final ScamEvidenceKind kind;
  final int priority;
  final String textKey;
  final Map<String, String> params;
  final String sourceLabel;
  final DateTime? sourceDate;
  final String? sourceUrl;
  final String? entityId;
  final String? advisoryId;
  final ScamEvidenceDirection direction;
}

class EvidenceEngineInput {
  const EvidenceEngineInput({
    required this.text,
    required this.locale,
    required this.localFlags,
    required this.urlFindings,
    this.senderType = ScamMessageSenderType.notSure,
    this.advisories = const [],
    this.attackStage,
    this.personalContext = PersonalContextSnapshot.empty,
  });

  final String text;
  final String locale;
  final List<String> localFlags;
  final List<ScamShieldUrlFinding> urlFindings;
  final ScamMessageSenderType senderType;
  final List<ScamAdvisory> advisories;
  final ScamAttackStage? attackStage;
  final PersonalContextSnapshot personalContext;
}

class ScamEvidenceHeadline {
  const ScamEvidenceHeadline({required this.textKey, this.params = const {}});

  final String textKey;
  final Map<String, String> params;
}
