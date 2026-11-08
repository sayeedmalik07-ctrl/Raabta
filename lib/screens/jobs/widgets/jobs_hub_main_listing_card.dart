import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_job_card.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_source_tier.dart';

/// Main Jobs feed card — [HubJobCard] plus hub-local actions (B3.2).
class JobsHubMainListingCard extends StatelessWidget {
  const JobsHubMainListingCard({
    super.key,
    required this.job,
    required this.locale,
    required this.isSaved,
    required this.onApply,
    required this.onSave,
    required this.onShare,
    this.linkedBusinessesById = const {},
  });

  final JobListing job;
  final String locale;
  final Map<String, BusinessListing> linkedBusinessesById;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final sourceTier =
        jobsHubSourceTierForListing(job, locale, linkedBusinessesById);
    return KeyedSubtree(
      key: Key('jobs_hub_listing_card_${job.id}'),
      child: HubJobCard(
        title: job.title,
        employerLine: jobsHubListingEmployerLine(job),
        freshnessLine: jobsHubListingFreshnessLine(job, locale),
        leadingInitial: job.companyInitial,
        sourceTierBadge: sourceTier,
        footer: _ListingActions(
          locale: locale,
          isSaved: isSaved,
          primaryCtaKey: jobsHubPrimaryCtaKey(job),
          onApply: onApply,
          onSave: onSave,
          onShare: onShare,
        ),
      ),
    );
  }
}

class _ListingActions extends StatelessWidget {
  const _ListingActions({
    required this.locale,
    required this.isSaved,
    required this.primaryCtaKey,
    required this.onApply,
    required this.onSave,
    required this.onShare,
  });

  final String locale;
  final bool isSaved;
  final String primaryCtaKey;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onApply,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandFamilyMain,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              JobsStrings.t(primaryCtaKey, locale),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isSaved
                      ? AppColors.brandFamilyMain
                      : AppColors.textSecondary,
                ),
                label: Text(
                  isSaved
                      ? CommonActionStrings.t('action_saved', locale)
                      : CommonActionStrings.t('action_save', locale),
                  style: TextStyle(
                    color: isSaved
                        ? AppColors.brandFamilyMain
                        : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  JobsStrings.t('jobs_share', locale),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
