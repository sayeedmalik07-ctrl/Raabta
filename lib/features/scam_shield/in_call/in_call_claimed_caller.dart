import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

/// User-selected "who they claim to be" — self-attested only, never verified.
enum InCallClaimedCaller {
  bankOrCard,
  policeMoiMetrash,
  mobileOperator,
  courierPostCustoms,
  employerOrAgency,
  embassyOrConsulate,
  familyInTrouble,
  techSupport,
  investmentOrPrize,
  other,
}

enum InCallNextActionKind {
  browseEntityChannels,
  familyVerificationKit,
  remoteAccessChecklist,
  paymentCheck,
  investmentCheck,
  pasteMessageCheck,
  browseAuthorityDirectory,
}

class InCallNextAction {
  const InCallNextAction({
    required this.kind,
    this.authorityDirectoryId,
    this.telecomDial,
  });

  final InCallNextActionKind kind;
  final String? authorityDirectoryId;
  final String? telecomDial;
}

enum InCallAskedFor {
  otpOrPin,
  cardDetails,
  qidOrDocuments,
  installOrScreenShare,
  sendMoney,
  nothing,
}

/// Deterministic routing — see [InCallAssistantRouting.resolveNextAction].
abstract final class InCallAssistantRouting {
  /// | Claimed caller | Next action |
  /// | bankOrCard | Browse entity channels (authority / directory guidance) |
  /// | policeMoiMetrash | moi authority entry |
  /// | mobileOperator | Telecom published numbers (confirm before dial) |
  /// | courierPostCustoms | Directory browse (delivery) |
  /// | employerOrAgency | Directory browse (employer) |
  /// | embassyOrConsulate | Card / website guidance (no entity phone asserted) |
  /// | familyInTrouble | Family Verification Kit |
  /// | techSupport | Remote access checklist (Phase 14 analogue) |
  /// | investmentOrPrize | Investment check or paste flow |
  /// | other | Authority directory browse |
  static InCallNextAction resolveNextAction(InCallClaimedCaller claimed) {
    return switch (claimed) {
      InCallClaimedCaller.bankOrCard => const InCallNextAction(
          kind: InCallNextActionKind.browseEntityChannels,
          authorityDirectoryId: 'qnb',
        ),
      InCallClaimedCaller.policeMoiMetrash => const InCallNextAction(
          kind: InCallNextActionKind.browseEntityChannels,
          authorityDirectoryId: 'moi',
        ),
      InCallClaimedCaller.mobileOperator => const InCallNextAction(
          kind: InCallNextActionKind.browseEntityChannels,
          authorityDirectoryId: 'ooredoo',
          telecomDial: '+97444200700',
        ),
      InCallClaimedCaller.courierPostCustoms => const InCallNextAction(
          kind: InCallNextActionKind.browseAuthorityDirectory,
        ),
      InCallClaimedCaller.employerOrAgency => const InCallNextAction(
          kind: InCallNextActionKind.browseAuthorityDirectory,
        ),
      InCallClaimedCaller.embassyOrConsulate => const InCallNextAction(
          kind: InCallNextActionKind.browseEntityChannels,
        ),
      InCallClaimedCaller.familyInTrouble => const InCallNextAction(
          kind: InCallNextActionKind.familyVerificationKit,
        ),
      InCallClaimedCaller.techSupport => const InCallNextAction(
          kind: InCallNextActionKind.remoteAccessChecklist,
        ),
      InCallClaimedCaller.investmentOrPrize => const InCallNextAction(
          kind: InCallNextActionKind.investmentCheck,
        ),
      InCallClaimedCaller.other => const InCallNextAction(
          kind: InCallNextActionKind.browseAuthorityDirectory,
        ),
    };
  }

  static ScamIncidentPrefillHint incidentHintForAsked(InCallAskedFor asked) {
    return switch (asked) {
      InCallAskedFor.otpOrPin => const ScamIncidentPrefillHint(
          sharedData: {ScamSharedDataCategory.otp},
          suggestedContact: {ScamContactChannel.phoneCall},
          timing: ScamIncidentTiming.justNow,
        ),
      InCallAskedFor.cardDetails => const ScamIncidentPrefillHint(
          sharedData: {ScamSharedDataCategory.cardDetails},
          suggestedContact: {ScamContactChannel.phoneCall},
          timing: ScamIncidentTiming.justNow,
        ),
      InCallAskedFor.qidOrDocuments => const ScamIncidentPrefillHint(
          sharedData: {
            ScamSharedDataCategory.qid,
            ScamSharedDataCategory.passport,
          },
          suggestedContact: {ScamContactChannel.phoneCall},
          timing: ScamIncidentTiming.justNow,
        ),
      InCallAskedFor.installOrScreenShare => const ScamIncidentPrefillHint(
          sharedData: {ScamSharedDataCategory.other},
          suggestedContact: {ScamContactChannel.phoneCall},
          timing: ScamIncidentTiming.justNow,
        ),
      InCallAskedFor.sendMoney => const ScamIncidentPrefillHint(
          outcomes: {ScamIncidentOutcome.moneyTransferred},
          suggestedContact: {ScamContactChannel.phoneCall},
          timing: ScamIncidentTiming.justNow,
        ),
      InCallAskedFor.nothing => const ScamIncidentPrefillHint(),
    };
  }

  static ScamImpersonationCategory impersonationFor(InCallClaimedCaller claimed) {
    return switch (claimed) {
      InCallClaimedCaller.bankOrCard => ScamImpersonationCategory.bank,
      InCallClaimedCaller.policeMoiMetrash =>
        ScamImpersonationCategory.government,
      InCallClaimedCaller.mobileOperator => ScamImpersonationCategory.telecom,
      InCallClaimedCaller.courierPostCustoms =>
        ScamImpersonationCategory.deliveryCompany,
      InCallClaimedCaller.employerOrAgency =>
        ScamImpersonationCategory.employer,
      _ => ScamImpersonationCategory.other,
    };
  }
}

/// Typed hints only — Incident Response screen still user-confirms everything.
class ScamIncidentPrefillHint {
  const ScamIncidentPrefillHint({
    this.impersonation,
    this.sharedData = const {},
    this.outcomes = const {},
    this.suggestedContact = const {},
    this.timing,
  });

  final ScamImpersonationCategory? impersonation;
  final Set<ScamSharedDataCategory> sharedData;
  final Set<ScamIncidentOutcome> outcomes;
  final Set<ScamContactChannel> suggestedContact;
  final ScamIncidentTiming? timing;

  ScamIncidentPrefill toPrefill({ScamImpersonationCategory? impersonation}) {
    return ScamIncidentPrefill(
      impersonationCategory: impersonation ?? this.impersonation,
      sharedData: sharedData,
      outcomes: outcomes.isEmpty ? null : outcomes,
      contactChannels: suggestedContact,
      timing: timing,
    );
  }
}

class ScamIncidentPrefill {
  const ScamIncidentPrefill({
    this.impersonationCategory,
    this.sharedData = const {},
    this.outcomes,
    this.contactChannels = const {},
    this.timing,
  });

  final ScamImpersonationCategory? impersonationCategory;
  final Set<ScamSharedDataCategory> sharedData;
  final Set<ScamIncidentOutcome>? outcomes;
  final Set<ScamContactChannel> contactChannels;
  final ScamIncidentTiming? timing;
}
