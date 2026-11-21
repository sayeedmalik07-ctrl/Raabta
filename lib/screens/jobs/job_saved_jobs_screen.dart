import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/qr_share_sheet.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/providers/saved_jobs_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_action_bar.dart';
import 'package:raabta/screens/jobs/widgets/job_listing_detail_body.dart';
import 'package:raabta/screens/jobs/widgets/job_listing_detail_sheet_shell.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_main_listing_card.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/qr/listing_deep_links.dart';
import 'package:url_launcher/url_launcher.dart';

class JobSavedJobsScreen extends ConsumerStatefulWidget {
  const JobSavedJobsScreen({super.key});

  @override
  ConsumerState<JobSavedJobsScreen> createState() => _JobSavedJobsScreenState();
}

class _JobSavedJobsScreenState extends ConsumerState<JobSavedJobsScreen> {
  final Set<String> _pendingSaveJobIds = {};
  bool _profileInitStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_ensureOwnedProfile());
    });
  }

  Future<void> _ensureOwnedProfile() async {
    if (_profileInitStarted) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final profile = ref.read(userAIProfileProvider);
    if (!UserProfileOwnership.needsInit(profile, user.uid)) return;
    _profileInitStarted = true;
    await ref.read(userAIProfileProvider.notifier).initProfile(user.uid);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleSave(String jobId) async {
    final locale = ref.read(userLanguageProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_sign_in_to_save_job', locale)),
        ),
      );
      context.push('/login');
      return;
    }

    if (_pendingSaveJobIds.contains(jobId)) return;
    _pendingSaveJobIds.add(jobId);

    try {
      if (UserProfileOwnership.needsInit(
        ref.read(userAIProfileProvider),
        user.uid,
      )) {
        await ref.read(userAIProfileProvider.notifier).initProfile(user.uid);
      }
      if (!mounted) return;

      final result =
          await ref.read(userAIProfileProvider.notifier).toggleSavedJob(jobId);
      if (!mounted) return;

      if (!result.profileReady || !result.localUpdated) return;

      if (result.remotePersisted &&
          result.outcome == SavedJobToggleOutcome.saved) {
        PostEngine().analytics.trackSave(
          listingId: jobId,
          verticalId: 'jobs',
        );
      }

      if (!result.remotePersisted) {
        final messageKey = result.outcome == SavedJobToggleOutcome.unsaved
            ? 'jobs_unsave_sync_failed'
            : 'jobs_save_sync_failed';
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(JobsStrings.t(messageKey, locale))),
        );
      }
    } finally {
      _pendingSaveJobIds.remove(jobId);
    }
  }

  void _handleApply(JobListing job) {
    final locale = ref.read(userLanguageProvider);
    final verification = getJobVerification(job, locale);
    if (verification.status == JobVerificationStatus.scam) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_scam_apply_blocked', locale)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (verification.status == JobVerificationStatus.warning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_review_before_apply', locale)),
          backgroundColor: AppColors.warning,
        ),
      );
    }
    _showJobDetailSheet(job);
  }

  void _showJobDetailSheet(JobListing job) {
    unawaited(
      ref.read(userAIProfileProvider.notifier).trackJobView(
            job.id,
            {
              'title': job.title,
              'category': job.category,
              'skills': job.requirements,
              'certifications': job.requirements,
            },
          ),
    );
    PostEngine().analytics.trackView(
      listingId: job.id,
      verticalId: 'jobs',
    );

    final locale = ref.read(userLanguageProvider);

    showJobListingDetailBottomSheet(
      context: context,
      watchLocale: false,
      localeWhenNotWatching: locale,
      buildContent: (context, scrollController, locale) {
        final applicationSectionKey = GlobalKey();
        return Consumer(
          builder: (context, ref, _) {
            final linkedBusinessesById =
                ref.read(savedJobsLinkedBusinessesProvider).valueOrNull ??
                    const {};
            final savedIds =
                ref.watch(userAIProfileProvider)?.savedJobIds ?? const [];
            final isSaved = savedIds.contains(job.id);
            return JobListingDetailSheetScaffold(
              scrollController: scrollController,
              job: job,
              body: JobListingDetailBody(
                job: job,
                locale: locale,
                linkedBusinessesById: linkedBusinessesById,
                onOpenUrl: _openUrl,
                onShareQr: () => _shareJob(job, locale),
                onDismissSheet: () => Navigator.pop(context),
                applicationSectionKey: applicationSectionKey,
              ),
              actionBar: JobDetailActionBar(
                job: job,
                locale: locale,
                isSaved: isSaved,
                onSave: () => unawaited(_toggleSave(job.id)),
                onShare: () => _shareJob(job, locale),
                onNativeApplyPrimary: () =>
                    scrollToJobDetailApplicationSection(applicationSectionKey),
              ),
            );
          },
        );
      },
    );
  }

  void _shareJob(JobListing job, String locale) {
    final verification = getJobVerification(job, locale);
    final badgeLabel = switch (verification.status) {
      JobVerificationStatus.verified =>
        JobsStrings.t('jobs_badge_verified', locale),
      JobVerificationStatus.warning =>
        JobsStrings.t('jobs_badge_warning', locale),
      JobVerificationStatus.scam => JobsStrings.t('jobs_badge_scam', locale),
    };
    showQrShareSheet(
      context,
      title: job.title,
      subtitle: '${job.company} · ${job.location}',
      caption: JobsStrings.format(
        'jobs_qr_caption',
        locale,
        params: {'badge': badgeLabel},
      ),
      qrData: ListingDeepLinks.jobListing(job.id),
    );
  }

  Widget _browseJobsButton(String locale) {
    return FilledButton(
      onPressed: () => context.go('/jobs'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandFamilyMain,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(JobsStrings.t('jobs_saved_browse_jobs', locale)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final savedIds =
        ref.watch(userAIProfileProvider.select((p) => p?.savedJobIds ?? const []));
    final resolutionAsync = ref.watch(savedJobListingsProvider);

    if (user == null) {
      return GlassScreenScaffold(
        title: JobsStrings.t('jobs_saved_title', locale),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  JobsStrings.t('jobs_saved_sign_in_prompt', locale),
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => context.push('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandFamilyMain,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(JobsStrings.t('jobs_saved_sign_in_cta', locale)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (UserProfileOwnership.needsInit(ref.watch(userAIProfileProvider), user.uid)) {
      return GlassScreenScaffold(
        title: JobsStrings.t('jobs_saved_title', locale),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.purpleGlow),
        ),
      );
    }

    return GlassScreenScaffold(
      title: JobsStrings.t('jobs_saved_title', locale),
      body: resolutionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.purpleGlow),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  JobsStrings.t('jobs_saved_load_error', locale),
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () =>
                      ref.read(savedJobListingsProvider.notifier).refresh(),
                  child: Text(JobsStrings.t('jobs_saved_retry', locale)),
                ),
              ],
            ),
          ),
        ),
        data: (resolution) {
          if (!resolution.hasSavedIds) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      JobsStrings.t('jobs_saved_empty_title', locale),
                      style: AppTypography.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      JobsStrings.t('jobs_saved_empty_body', locale),
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _browseJobsButton(locale),
                  ],
                ),
              ),
            );
          }

          if (resolution.allUnavailable) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      JobsStrings.t('jobs_saved_unavailable_title', locale),
                      style: AppTypography.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      JobsStrings.t('jobs_saved_unavailable_body', locale),
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _browseJobsButton(locale),
                  ],
                ),
              ),
            );
          }

          final savedSet = savedIds.toSet();
          final linkedBusinessesById =
              ref.watch(savedJobsLinkedBusinessesProvider).valueOrNull ??
                  const {};
          return RefreshIndicator(
            color: AppColors.brandFamilyMain,
            onRefresh: () =>
                ref.read(savedJobListingsProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: resolution.listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final job = resolution.listings[index];
                return JobsHubMainListingCard(
                  key: Key('jobs_saved_listing_card_${job.id}'),
                  job: job,
                  locale: locale,
                  linkedBusinessesById: linkedBusinessesById,
                  isSaved: savedSet.contains(job.id),
                  onApply: () => _handleApply(job),
                  onSave: () => unawaited(_toggleSave(job.id)),
                  onShare: () => _shareJob(job, locale),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
