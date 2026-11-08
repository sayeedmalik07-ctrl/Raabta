/// Bundled moment triggers — do not extend without product review.
enum ForewarningMomentId {
  jobApply('job_apply'),
  housingDepositViewing('housing_deposit_viewing'),
  marketplacePay('marketplace_pay'),
  remittanceFamilyEmergency('remittance_family_emergency'),
  serviceQuoteAdvance('service_quote_advance'),
  visaProUnofficialAgent('visa_pro_unofficial_agent');

  const ForewarningMomentId(this.storageKey);

  final String storageKey;

  static ForewarningMomentId? fromStorageKey(String key) {
    for (final id in values) {
      if (id.storageKey == key) return id;
    }
    return null;
  }
}
