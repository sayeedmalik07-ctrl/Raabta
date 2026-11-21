import 'package:raabta/core/widgets/hub/hub_source_tier_badge.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_employer_source_tier.dart';

export 'package:raabta/screens/jobs/widgets/jobs_hub_employer_source_tier.dart';

/// Maps listing source metadata to hub source-tier badges when explicitly supported.
({String label, HubJobSourceTier tier})? jobsHubSourceTierForListing(
  JobListing job,
  String locale, [
  Map<String, BusinessListing> linkedBusinessesById = const {},
]) {
  return jobsHubSourceTierBadgeForListing(
    job,
    locale,
    linkedBusinessesById,
  );
}

String jobsHubPrimaryCtaKey(JobListing job) =>
    job.supportsApplicationTracking ? 'jobs_apply' : 'jobs_view_listing';

String jobsHubListingFreshnessLine(JobListing job, String locale) {
  return JobsStrings.format(
    'jobs_posted_applicants_type',
    locale,
    params: {
      'posted': job.posted,
      'count': '${job.applicants}',
      'type': job.type,
    },
  );
}

String jobsHubListingEmployerLine(JobListing job) =>
    '${job.company} · ${job.location}';
