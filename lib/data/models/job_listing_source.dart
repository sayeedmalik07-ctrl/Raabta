/// Provenance of a job listing — gates Raabta-native application tracking.
enum JobListingSource {
  raabtaNative('raabta_native'),
  aggregatedExternal('aggregated_external');

  const JobListingSource(this.storageValue);
  final String storageValue;

  static JobListingSource fromStored(String? raw) {
    if (raw == aggregatedExternal.storageValue) {
      return JobListingSource.aggregatedExternal;
    }
    return JobListingSource.raabtaNative;
  }

  bool get supportsApplicationTracking =>
      this == JobListingSource.raabtaNative;
}
