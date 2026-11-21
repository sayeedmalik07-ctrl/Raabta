import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_response_priority_engine.dart';

String contactChannelLabelKey(ScamContactChannel channel) {
  return switch (channel) {
    ScamContactChannel.phoneCall => 'ss_contact_phone',
    ScamContactChannel.sms => 'ss_contact_sms',
    ScamContactChannel.whatsApp => 'ss_contact_whatsapp',
    ScamContactChannel.email => 'ss_contact_email',
    ScamContactChannel.socialMedia => 'ss_contact_social',
    ScamContactChannel.website => 'ss_contact_website',
    ScamContactChannel.qrCode => 'ss_contact_qr',
    ScamContactChannel.inPerson => 'ss_contact_in_person',
    ScamContactChannel.messagingApp => 'ss_contact_messaging',
    ScamContactChannel.other => 'ss_contact_other',
  };
}

String incidentTimingLabelKey(ScamIncidentTiming timing) {
  return switch (timing) {
    ScamIncidentTiming.justNow => 'ss_timing_just_now',
    ScamIncidentTiming.within1Hour => 'ss_timing_1h',
    ScamIncidentTiming.today => 'ss_timing_today',
    ScamIncidentTiming.yesterday => 'ss_timing_yesterday',
    ScamIncidentTiming.within7Days => 'ss_timing_7d',
    ScamIncidentTiming.moreThan7Days => 'ss_timing_7d_plus',
    ScamIncidentTiming.unknown => 'ss_timing_unknown',
  };
}

String sharedDataLabelKey(ScamSharedDataCategory category) {
  return switch (category) {
    ScamSharedDataCategory.qid => 'ss_shared_qid',
    ScamSharedDataCategory.passport => 'ss_shared_passport',
    ScamSharedDataCategory.drivingLicence => 'ss_shared_driving',
    ScamSharedDataCategory.otp => 'ss_shared_otp',
    ScamSharedDataCategory.bankDetails => 'ss_shared_bank',
    ScamSharedDataCategory.cardDetails => 'ss_shared_card',
    ScamSharedDataCategory.password => 'ss_shared_password',
    ScamSharedDataCategory.phoneConfirmation => 'ss_shared_phone_confirm',
    ScamSharedDataCategory.simEsimInfo => 'ss_shared_sim',
    ScamSharedDataCategory.other => 'ss_shared_other',
  };
}

String outcomeLabelKey(ScamIncidentOutcome outcome) {
  return switch (outcome) {
    ScamIncidentOutcome.nothingYet => 'ss_outcome_nothing',
    ScamIncidentOutcome.simPhoneStopped => 'ss_outcome_sim_stopped',
    ScamIncidentOutcome.unexpectedOtp => 'ss_outcome_unexpected_otp',
    ScamIncidentOutcome.passwordChanged => 'ss_outcome_password_changed',
    ScamIncidentOutcome.unknownTransaction => 'ss_outcome_unknown_tx',
    ScamIncidentOutcome.moneyTransferred => 'ss_outcome_money',
    ScamIncidentOutcome.cardCharged => 'ss_outcome_card_charged',
    ScamIncidentOutcome.accountLocked => 'ss_outcome_account_locked',
  };
}

String impersonationLabelKey(ScamImpersonationCategory category) {
  return switch (category) {
    ScamImpersonationCategory.government => 'ss_impersonation_government',
    ScamImpersonationCategory.bank => 'ss_impersonation_bank',
    ScamImpersonationCategory.telecom => 'ss_impersonation_telecom',
    ScamImpersonationCategory.deliveryCompany => 'ss_impersonation_delivery',
    ScamImpersonationCategory.employer => 'ss_impersonation_employer',
    ScamImpersonationCategory.other => 'ss_impersonation_other',
  };
}

bool showsSecondaryScamPanel(ScamIncidentAssessmentResult result) =>
    ScamResponsePriorityEngine.showsSecondaryScamWarning(result.responsePriority);
