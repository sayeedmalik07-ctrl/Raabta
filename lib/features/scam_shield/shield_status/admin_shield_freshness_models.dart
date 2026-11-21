class AdminDirectoryStalenessEntry {
  const AdminDirectoryStalenessEntry({
    required this.id,
    required this.displayName,
    required this.daysSinceVerified,
    required this.lastVerified,
  });

  final String id;
  final String displayName;
  final int daysSinceVerified;
  final DateTime? lastVerified;
}

class AdminShieldFreshnessReport {
  const AdminShieldFreshnessReport({
    required this.directoryOlderThanAttentionDays,
    required this.directoryOlderThanStaleDays,
    required this.directoryUnverifiedHiddenCount,
    required this.contentCardUnverifiedCount,
    required this.activeAdvisoriesCount,
    required this.expiredAdvisoriesCount,
    required this.daysSinceLastAdvisoryPublish,
    required this.phraseDictionaryLastReviewed,
    required this.legalSourcesLastUpdated,
    required this.featureFlags,
    required this.complianceFlagsResolved,
    required this.complianceFetchStale,
    required this.domainAgeEndpointEnabled,
    required this.linkUnrollEndpointEnabled,
    required this.endpointHealthRecorded,
  });

  final List<AdminDirectoryStalenessEntry> directoryOlderThanAttentionDays;
  final List<AdminDirectoryStalenessEntry> directoryOlderThanStaleDays;
  final int directoryUnverifiedHiddenCount;
  final int contentCardUnverifiedCount;
  final int activeAdvisoriesCount;
  final int expiredAdvisoriesCount;
  final int? daysSinceLastAdvisoryPublish;
  final DateTime? phraseDictionaryLastReviewed;
  final DateTime legalSourcesLastUpdated;
  final Map<String, bool> featureFlags;
  final Map<String, bool> complianceFlagsResolved;
  final bool complianceFetchStale;
  final bool domainAgeEndpointEnabled;
  final bool linkUnrollEndpointEnabled;
  final bool endpointHealthRecorded;
}
