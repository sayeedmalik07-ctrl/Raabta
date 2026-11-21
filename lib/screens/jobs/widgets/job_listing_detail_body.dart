import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/hub/hub_source_tier_badge.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/offer_calculator/domain/job_offer_salary_hint_parser.dart';
import 'package:raabta/features/jobs/offer_calculator/l10n/job_offer_calculator_strings.dart';
import 'package:raabta/features/jobs/offer_calculator/presentation/screens/job_offer_calculator_screen.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/screens/jobs/widgets/job_aggregated_external_apply_compliance.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_application_section.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_contact_section.dart';
import 'package:raabta/screens/jobs/widgets/job_listing_trust_section.dart';
import 'package:raabta/screens/jobs/widgets/job_requirements_display.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_source_tier.dart';
import 'package:raabta/services/report_service.dart';
import 'package:raabta/widgets/ai/job_match_badge.dart';

/// Shared scroll content for job listing detail (Hub and Saved Jobs).
class JobListingDetailBody extends ConsumerWidget {
  const JobListingDetailBody({
    super.key,
    required this.job,
    required this.locale,
    required this.linkedBusinessesById,
    required this.onOpenUrl,
    required this.onShareQr,
    required this.onDismissSheet,
    required this.applicationSectionKey,
  });

  final JobListing job;
  final String locale;
  final Map<String, BusinessListing> linkedBusinessesById;
  final Future<void> Function(String url) onOpenUrl;
  final VoidCallback onShareQr;
  final VoidCallback onDismissSheet;
  final GlobalKey applicationSectionKey;

  static const Key applicationSectionAnchorKey =
      Key('jobs_detail_application_section');

  static Color contentCheckStatusColor(JobVerificationStatus status) {
    switch (status) {
      case JobVerificationStatus.verified:
        return AppColors.success;
      case JobVerificationStatus.warning:
        return AppColors.warning;
      case JobVerificationStatus.scam:
        return AppColors.error;
    }
  }

  static String contentCheckBadgeLabel(
    JobVerificationStatus status,
    String locale,
  ) {
    switch (status) {
      case JobVerificationStatus.verified:
        return JobsStrings.t('jobs_badge_verified', locale);
      case JobVerificationStatus.warning:
        return JobsStrings.t('jobs_badge_warning', locale);
      case JobVerificationStatus.scam:
        return JobsStrings.t('jobs_badge_scam', locale);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verification = getJobVerification(job, locale);
    final color = contentCheckStatusColor(verification.status);
    final badgeLabel = contentCheckBadgeLabel(verification.status, locale);
    final sourceTier = jobsHubSourceTierForListing(
      job,
      locale,
      linkedBusinessesById,
    );

    return KeyedSubtree(
      key: const Key('job_listing_detail_body'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClassifiedsHostNotice(locale: locale),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(job.title, style: AppTypography.headline1),
              ),
              StatusBadge(label: badgeLabel, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text('🏢 ${job.company}', style: AppTypography.body),
          if (sourceTier != null) ...[
            const SizedBox(height: 8),
            HubSourceTierBadge(
              label: sourceTier.label,
              tier: sourceTier.tier,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${job.location} · ${job.salary} · ${job.type}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {
                final hint =
                    JobOfferSalaryHintParser.fromListingText(job.salary);
                context.push(JobOfferCalculatorScreen.route(
                  initialSalary: hint,
                ));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.chipWage,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                JobOfferCalculatorStrings.t('joc_detail_link', locale),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (verification.status != JobVerificationStatus.verified)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    verification.status == JobVerificationStatus.scam
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      verification.status == JobVerificationStatus.scam
                          ? JobsStrings.t('jobs_scam_detail_banner', locale)
                          : JobsStrings.t('jobs_warning_detail_banner', locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: color,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            JobsStrings.t('jobs_field_description', locale),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          UserGeneratedTextWithLinkSafety(
            text: job.description,
            locale: locale,
            surface: LinkSafetySurface.jobsListing,
            style: AppTypography.body.copyWith(height: 1.5),
            onReportPost: () async {
              try {
                await ReportService().submitReport(
                  type: AdminReportType.job,
                  title: JobsStrings.format(
                    'jobs_report_title',
                    locale,
                    params: {'title': job.title},
                  ),
                  description: JobsStrings.format(
                    'jobs_report_description',
                    locale,
                    params: {'title': job.title, 'company': job.company},
                  ),
                  targetId: job.id,
                  targetType: 'job',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        JobsStrings.format(
                          'jobs_report_submitted',
                          locale,
                          params: {'title': job.title},
                        ),
                      ),
                    ),
                  );
                }
              } catch (_) {}
            },
          ),
          const SizedBox(height: 16),
          Text(
            JobsStrings.t('jobs_requirements_heading', locale),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          JobRequirementsDisplay(
            requirements: job.effectiveRequirements,
            locale: locale,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.smart_toy_outlined,
                      color: AppColors.cyanGlow,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      JobsStrings.t('jobs_full_ai_analysis', locale),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  verification.analysisText,
                  style: TextStyle(color: color, height: 1.4),
                ),
                if (job.note != null) ...[
                  const SizedBox(height: 8),
                  Text(job.note!, style: AppTypography.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          JobMatchBadge(
            jobData: jobListingToMatchData(job),
            compact: false,
            enrichFromCv: true,
          ),
          const SizedBox(height: 20),
          JobListingTrustSection(
            companyName: job.company,
            locale: locale,
          ),
          const SizedBox(height: 20),
          if (job.supportsApplicationTracking) ...[
            OutlinedButton.icon(
              onPressed: () async {
                onDismissSheet();
                final hasCv =
                    await ref.read(cvRepositoryProvider).hasSavedCvInVault();
                if (!context.mounted) return;
                if (hasCv) {
                  context.push(
                    '/jobs/cv-preview?attachJob=${Uri.encodeComponent(job.id)}',
                  );
                } else {
                  context.push('/jobs/cv-start');
                }
              },
              icon: const Icon(Icons.description_outlined),
              label: Text(JobsStrings.t('jobs_no_cv_cta', locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purpleGlow,
                side: BorderSide(
                  color: AppColors.purpleGlow.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
          KeyedSubtree(
            key: applicationSectionKey,
            child: KeyedSubtree(
              key: applicationSectionAnchorKey,
              child: JobDetailApplicationSection(job: job, locale: locale),
            ),
          ),
          if (!job.supportsApplicationTracking) ...[
            const SizedBox(height: 12),
            JobAggregatedExternalApplyCompliance(locale: locale),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 12),
          JobDetailContactSection(
            job: job,
            locale: locale,
            onOpenUrl: onOpenUrl,
            whatsappMessage: JobsStrings.format(
              'jobs_whatsapp_interest',
              locale,
              params: {'title': job.title, 'company': job.company},
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShareQr,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(JobsStrings.t('jobs_share_qr', locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amberGlow,
                side: BorderSide(
                  color: AppColors.amberGlow.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () async {
                onDismissSheet();
                try {
                  await ReportService().submitReport(
                    type: AdminReportType.job,
                    title: JobsStrings.format(
                      'jobs_report_title',
                      locale,
                      params: {'title': job.title},
                    ),
                    description: JobsStrings.format(
                      'jobs_report_description',
                      locale,
                      params: {'title': job.title, 'company': job.company},
                    ),
                    targetId: job.id,
                    targetType: 'job',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          JobsStrings.format(
                            'jobs_report_submitted',
                            locale,
                            params: {'title': job.title},
                          ),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          JobsStrings.t('jobs_report_failed', locale),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                JobsStrings.t('jobs_report_this_job', locale),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
