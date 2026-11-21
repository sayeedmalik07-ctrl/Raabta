enum CivicChannelType {
  officialWebsite('official_website'),
  verifiedPhone('verified_phone'),
  appStoreListing('app_store_listing'),
  raabtaFlow('raabta_flow');

  const CivicChannelType(this.jsonValue);

  final String jsonValue;

  static CivicChannelType? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    for (final value in CivicChannelType.values) {
      if (value.jsonValue == raw.trim()) return value;
    }
    return null;
  }
}

enum CivicVerificationStatus {
  unverified('unverified'),
  verified('verified');

  const CivicVerificationStatus(this.jsonValue);

  final String jsonValue;

  static CivicVerificationStatus tryParse(String? raw) {
    if (raw == null) return CivicVerificationStatus.unverified;
    for (final value in CivicVerificationStatus.values) {
      if (value.jsonValue == raw.trim()) return value;
    }
    return CivicVerificationStatus.unverified;
  }
}
