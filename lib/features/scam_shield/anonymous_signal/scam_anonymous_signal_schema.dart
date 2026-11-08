/// Phase 20 wire schema v1 — counters-only categories (mirrors server enums).
abstract final class ScamAnonymousSignalSchema {
  static const version = 1;
  static const maxArchetypes = 2;
  static const maxEvidenceKinds = 6;
  static const maxEventsPerBatch = 20;
  static const maxEventsPerInstallPerDay = 20;

  static const allowedArchetypes = {
    'fake_moi_fine',
    'job_visa_fee',
    'rental_deposit_scam',
    'nas_address_verify',
    'telecom_sim_block',
    'bank_kyc_phish',
    'delivery_customs_fee',
    'investment_guaranteed',
  };
}

enum ScamAnonymousSignalChannel {
  sms,
  whatsapp,
  email,
  call,
  social,
  classifiedsChat,
  other,
  unknown,
}

enum ScamAnonymousSignalRiskBand { none, medium, high }

enum ScamAnonymousSignalClaimedCategory {
  government,
  banking,
  telecom,
  airline,
  utilities,
  health,
  other,
  none,
}

enum ScamAnonymousSignalFeedback { none, helpful, legitFalseAlarm }

class ScamAnonymousSignalEvent {
  const ScamAnonymousSignalEvent({
    required this.dayUtc,
    required this.channel,
    required this.archetypes,
    required this.evidenceKinds,
    required this.riskBand,
    required this.claimedEntityCategory,
    required this.uiLocale,
    required this.feedback,
  });

  final String dayUtc;
  final ScamAnonymousSignalChannel channel;
  final List<String> archetypes;
  final List<String> evidenceKinds;
  final ScamAnonymousSignalRiskBand riskBand;
  final ScamAnonymousSignalClaimedCategory claimedEntityCategory;
  final String uiLocale;
  final ScamAnonymousSignalFeedback feedback;

  Map<String, dynamic> toJson() => {
        'v': ScamAnonymousSignalSchema.version,
        'day': dayUtc,
        'channel': _channelWire(channel),
        'archetypes': archetypes,
        'evidenceKinds': evidenceKinds,
        'riskBand': riskBand.name,
        'claimedEntityCategory': _claimedWire(claimedEntityCategory),
        'uiLocale': uiLocale,
        'feedback': _feedbackWire(feedback),
      };

  static String _channelWire(ScamAnonymousSignalChannel c) => switch (c) {
        ScamAnonymousSignalChannel.classifiedsChat => 'classifieds_chat',
        _ => c.name,
      };

  static String _claimedWire(ScamAnonymousSignalClaimedCategory c) => c.name;

  static String _feedbackWire(ScamAnonymousSignalFeedback f) => switch (f) {
        ScamAnonymousSignalFeedback.legitFalseAlarm => 'legit_false_alarm',
        _ => f.name,
      };
}
