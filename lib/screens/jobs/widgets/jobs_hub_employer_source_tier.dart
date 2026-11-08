import 'package:raabta/core/widgets/hub/hub_source_tier_badge.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/employer_identity_verification.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/data/models/job_listing_source.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Hub employer segment filter (main feed only).
enum JobsHubEmployerSegment {
  all,
  verifiedEmployers,
  communityPosts,
}

/// Source tier for native vs external jobs — independent of [getJobVerification].
enum JobsHubEmployerSourceTier {
  verifiedEmployer,
  communityPost,
  external,
}

JobsHubEmployerSourceTier jobsHubEmployerSourceTier(
  JobListing job,
  Map<String, BusinessListing> linkedBusinessesById,
) {
  if (job.listingSource == JobListingSource.aggregatedExternal) {
    return JobsHubEmployerSourceTier.external;
  }

  final businessId = job.businessId?.trim();
  if (businessId != null && businessId.isNotEmpty) {
    final business = linkedBusinessesById[businessId];
    if (business != null &&
        business.employerIdentityVerification?.status ==
            EmployerIdentityVerificationStatus.verified) {
      return JobsHubEmployerSourceTier.verifiedEmployer;
    }
  }

  return JobsHubEmployerSourceTier.communityPost;
}

bool jobsHubMatchesEmployerSegment(
  JobListing job,
  JobsHubEmployerSegment segment,
  Map<String, BusinessListing> linkedBusinessesById,
) {
  switch (segment) {
    case JobsHubEmployerSegment.all:
      return true;
    case JobsHubEmployerSegment.verifiedEmployers:
      return jobsHubEmployerSourceTier(job, linkedBusinessesById) ==
          JobsHubEmployerSourceTier.verifiedEmployer;
    case JobsHubEmployerSegment.communityPosts:
      return jobsHubEmployerSourceTier(job, linkedBusinessesById) ==
          JobsHubEmployerSourceTier.communityPost;
  }
}

/// Maps listing + linked businesses to hub source-tier badge metadata.
({String label, HubJobSourceTier tier})? jobsHubSourceTierBadgeForListing(
  JobListing job,
  String locale,
  Map<String, BusinessListing> linkedBusinessesById,
) {
  switch (jobsHubEmployerSourceTier(job, linkedBusinessesById)) {
    case JobsHubEmployerSourceTier.external:
      return null;
    case JobsHubEmployerSourceTier.verifiedEmployer:
      return (
        label: JobsStrings.t('jobs_hub_source_verified_employer', locale),
        tier: HubJobSourceTier.verifiedEmployer,
      );
    case JobsHubEmployerSourceTier.communityPost:
      return (
        label: JobsStrings.t('jobs_hub_source_community_post', locale),
        tier: HubJobSourceTier.communityPost,
      );
  }
}
