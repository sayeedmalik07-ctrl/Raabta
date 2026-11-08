/// Scan-derived topic for Phase 23 truth-engine bridges (one per assessment).
enum ScamBridgeTopic {
  none,
  jobOffer,
  recruitmentFee,
  housingDeposit,
  visaOrSponsorshipAgent,
  finalSettlementOrSalary,
  insuranceCall,
  remittanceEmergency,
  governmentFineOrFee,
  investment,
  recoveryOffer,
  eventTickets,
}

extension ScamBridgeTopicX on ScamBridgeTopic {
  bool get isExplicit => this != ScamBridgeTopic.none;
}
