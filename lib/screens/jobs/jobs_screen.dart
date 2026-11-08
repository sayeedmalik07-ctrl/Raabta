import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/qr_share_sheet.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/icons/service_screen_icons.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/profile/advanced/widgets/advanced_profile_card.dart';
import 'package:raabta/data/categories/job_categories.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_feed_footer_notice.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_employer_source_tier.dart';
import 'package:raabta/screens/jobs/widgets/jobs_hub_main_listing_card.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_track_record_lookup_screen.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/ai/job_match_service.dart';
import 'package:raabta/services/qr/listing_deep_links.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/screens/jobs/widgets/job_aggregated_external_apply_compliance.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_contact_section.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_action_bar.dart';
import 'package:raabta/screens/jobs/widgets/job_listing_detail_body.dart';
import 'package:raabta/screens/jobs/widgets/job_listing_detail_sheet_shell.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/features/jobs/offer_calculator/presentation/screens/job_offer_calculator_screen.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/presentation/widgets/save_search_button.dart';
import 'package:url_launcher/url_launcher.dart';

String _jobsHubPrimaryCtaKey(JobListing job) =>
    job.supportsApplicationTracking ? 'jobs_apply' : 'jobs_view_listing';

@visibleForTesting
Widget jobsAggregatedApplyComplianceForTest(String locale) =>
    JobAggregatedExternalApplyCompliance(locale: locale);

@visibleForTesting
Widget jobsDetailContactSectionForTest({
  required JobListing job,
  required String locale,
}) =>
    JobDetailContactSection(
      job: job,
      locale: locale,
      onOpenUrl: (_) async {},
      whatsappMessage: 'test',
    );

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key, this.routeParameters});

  final SearchRouteParameters? routeParameters;

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  JobsHubEmployerSegment _employerSegment = JobsHubEmployerSegment.all;
  SearchRouteParameters? _routeFilters;
  final Set<String> _pendingSaveJobIds = {};

  @override
  void initState() {
    super.initState();
    _routeFilters = widget.routeParameters;
    _applyRouteParameters(_routeFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_ensureOwnedProfileForJobs());
    });
  }

  Future<void> _ensureOwnedProfileForJobs() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final profile = ref.read(userAIProfileProvider);
    if (!UserProfileOwnership.needsInit(profile, user.uid)) return;
    await ref.read(userAIProfileProvider.notifier).initProfile(user.uid);
  }

  void _applyRouteParameters(SearchRouteParameters? params) {
    if (params == null || params.isEmpty) return;

    if (params.jobQuery != null && params.jobQuery!.trim().isNotEmpty) {
      _searchController.text = params.jobQuery!.trim();
    } else if (params.jobCategory != null &&
        params.jobCategory!.trim().isNotEmpty) {
      _searchController.text = params.jobCategory!.trim();
    }

    if (params.jobCategory != null && params.jobCategory!.trim().isNotEmpty) {
      final index = kJobCategories.indexWhere(
        (c) => c.toLowerCase() == params.jobCategory!.trim().toLowerCase(),
      );
      if (index >= 0) _selectedFilter = index;
    }
  }

  List<JobListing> _filteredJobs(
    List<JobListing> allJobs,
    Map<String, BusinessListing> linkedBusinessesById,
  ) {
    var jobs = filterJobs(
      source: allJobs,
      query: _searchController.text.trim().toLowerCase(),
      categoryFilter: kJobCategories[_selectedFilter],
      area: _routeFilters?.area,
      minSalary: _routeFilters?.minSalary,
      maxSalary: _routeFilters?.maxSalary,
      jobCategory: _routeFilters?.jobCategory,
      jobQuery: _routeFilters?.jobQuery,
    );
    final profile = ref.read(userAIProfileProvider);
    if (profile != null) {
      jobs = List<JobListing>.from(jobs)
        ..sort((a, b) => _matchScore(b).compareTo(_matchScore(a)));
    }
    if (_employerSegment != JobsHubEmployerSegment.all) {
      jobs = jobs
          .where(
            (job) => jobsHubMatchesEmployerSegment(
              job,
              _employerSegment,
              linkedBusinessesById,
            ),
          )
          .toList();
    }
    return jobs;
  }

  List<JobListing> _featuredJobs(List<JobListing> allJobs, String locale) =>
      allJobs
          .where(
            (j) =>
                getJobVerification(j, locale).status ==
                JobVerificationStatus.verified,
          )
          .take(3)
          .toList();

  List<JobListing> _urgentJobs(List<JobListing> allJobs) =>
      allJobs.where((j) => j.isRecentlyPosted).take(3).toList();

  int _matchedJobCount(List<JobListing> allJobs) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return 0;
    final matcher = ref.read(jobMatchServiceProvider);
    return allJobs
        .where(
          (j) =>
              matcher.evaluateMatch(jobListingToMatchData(j), profile).matchScore >=
              72,
        )
        .length;
  }

  // Kept for hub match analytics parity; not shown on Jobs Hub after R3.
  // ignore: unused_element
  int? _averageMatchRate(List<JobListing> allJobs) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null || allJobs.isEmpty) return null;
    final matcher = ref.read(jobMatchServiceProvider);
    final scores = allJobs
        .map((j) => matcher.evaluateMatch(jobListingToMatchData(j), profile).matchScore)
        .toList();
    if (scores.isEmpty) return null;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  int _matchScore(JobListing job) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return 0;
    return ref
        .read(jobMatchServiceProvider)
        .evaluateMatch(jobListingToMatchData(job), profile)
        .matchScore;
  }

  ({String company, String industry, int count})? _spotlightCompany(
    List<JobListing> allJobs,
  ) {
    if (allJobs.isEmpty) return null;
    final counts = <String, int>{};
    for (final job in allJobs) {
      counts[job.company] = (counts[job.company] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final sample = allJobs.firstWhere((j) => j.company == top.key);
    return (company: top.key, industry: sample.industry, count: top.value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hub carousel badges: content-check signal, not employer identity (2A.4).
  Color _contentCheckBadgeColor(JobVerificationStatus status) {
    switch (status) {
      case JobVerificationStatus.verified:
        return AppColors.info;
      case JobVerificationStatus.warning:
        return AppColors.warning;
      case JobVerificationStatus.scam:
        return AppColors.error;
    }
  }

  String _badgeLabel(JobVerificationStatus status, String locale) {
    switch (status) {
      case JobVerificationStatus.verified:
        return JobsStrings.t('jobs_badge_verified', locale);
      case JobVerificationStatus.warning:
        return JobsStrings.t('jobs_badge_warning', locale);
      case JobVerificationStatus.scam:
        return JobsStrings.t('jobs_badge_scam', locale);
    }
  }

  String _miniAnalysisText(JobVerificationResult verification, String locale) {
    switch (verification.status) {
      case JobVerificationStatus.verified:
        return JobsStrings.t('jobs_mini_analysis_verified', locale);
      case JobVerificationStatus.warning:
        return JobsStrings.t('jobs_mini_analysis_warning', locale);
      case JobVerificationStatus.scam:
        return JobsStrings.t('jobs_mini_analysis_scam', locale);
    }
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

  void _openJobQrShare(JobListing job, String locale) {
    final verification = getJobVerification(job, locale);
    showQrShareSheet(
      context,
      title: job.title,
      subtitle: '${job.company} · ${job.location}',
      caption: JobsStrings.format(
        'jobs_qr_caption',
        locale,
        params: {'badge': _badgeLabel(verification.status, locale)},
      ),
      qrData: ListingDeepLinks.jobListing(job.id),
    );
  }

  Future<void> _shareJob(JobListing job, String locale) async {
    _openJobQrShare(job, locale);
  }

  void _applyToJob(JobListing job, JobVerificationResult verification) {
    final locale = ref.read(userLanguageProvider);
    if (verification.status == JobVerificationStatus.scam) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_scam_apply_blocked', locale)),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (verification.status == JobVerificationStatus.warning) {
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
      watchLocale: true,
      localeWhenNotWatching: locale,
      buildContent: (context, scrollController, locale) {
        final applicationSectionKey = GlobalKey();
        return Consumer(
          builder: (context, ref, _) {
            final linkedBusinessesById =
                ref.read(jobsLinkedBusinessesProvider).valueOrNull ?? const {};
            final savedJobIds =
                ref.watch(userAIProfileProvider)?.savedJobIds ?? const [];
            final isSaved = savedJobIds.contains(job.id);
            return JobListingDetailSheetScaffold(
              scrollController: scrollController,
              job: job,
              body: JobListingDetailBody(
                job: job,
                locale: locale,
                linkedBusinessesById: linkedBusinessesById,
                onOpenUrl: _openUrl,
                onShareQr: () => _openJobQrShare(job, locale),
                onDismissSheet: () => Navigator.pop(context),
                applicationSectionKey: applicationSectionKey,
              ),
              actionBar: JobDetailActionBar(
                job: job,
                locale: locale,
                isSaved: isSaved,
                onSave: () => unawaited(_toggleSave(job.id)),
                onShare: () => unawaited(_shareJob(job, locale)),
                onNativeApplyPrimary: () =>
                    scrollToJobDetailApplicationSection(applicationSectionKey),
              ),
            );
          },
        );
      },
    );
  }

  void _showPostJobSheet() {
    context.push('/jobs/post');
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final jobsAsync = ref.watch(jobsCatalogProvider);
    final savedJobIds =
        ref.watch(userAIProfileProvider)?.savedJobIds ?? const [];

    return jobsAsync.when(
      loading: () => AnimatedAuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: const SafeArea(
            child: HubLoadingPlaceholder(),
          ),
        ),
      ),
      error: (e, _) => AnimatedAuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Text(
                '${JobsStrings.t('jobs_load_error', locale)}: $e',
                style: AppTypography.body,
              ),
            ),
          ),
        ),
      ),
      data: (allJobs) {
        final linkedBusinessesById =
            ref.watch(jobsLinkedBusinessesProvider).valueOrNull ?? const {};
        return _buildJobsContent(
          context,
          locale,
          allJobs,
          savedJobIds,
          linkedBusinessesById,
        );
      },
    );
  }

  Widget _buildJobsContent(
    BuildContext context,
    String locale,
    List<JobListing> allJobs,
    List<String> savedJobIds,
    Map<String, BusinessListing> linkedBusinessesById,
  ) {
    bool isJobSaved(String jobId) => savedJobIds.contains(jobId);
    final jobs = _filteredJobs(allJobs, linkedBusinessesById);
    final featured = _featuredJobs(allJobs, locale);
    final urgent = _urgentJobs(allJobs);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostJobSheet,
        backgroundColor: AppColors.brandFamilyMain,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildLandingChrome(context, locale)),
            SliverToBoxAdapter(child: _buildHubSummaryStrip(locale)),
            SliverToBoxAdapter(child: _buildQuickActionsRow(locale)),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(child: _buildEmployerSegmentChips(locale)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: AdvancedProfileNudgeBanner(),
              ),
            ),
            SliverToBoxAdapter(child: _buildAiMatchBanner(allJobs, locale)),
            if (featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: HomeSectionHeader(
                    overline: JobsStrings.t('jobs_featured_jobs', locale),
                    title: JobsStrings.t('jobs_top_picks', locale),
                    leadingIcon: Icons.star_outline_rounded,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final badges = [
                        PremiumJobBadge.featured,
                        PremiumJobBadge.urgent,
                        PremiumJobBadge.spotlight,
                      ];
                      final featuredJob = featured[index];
                      final featuredVerification =
                          getJobVerification(featuredJob, locale);
                      return _PremiumJobCard(
                        job: featuredJob,
                        locale: locale,
                        badge: badges[index % badges.length],
                        isSaved: isJobSaved(featuredJob.id),
                        onApply: () => _applyToJob(
                          featuredJob,
                          featuredVerification,
                        ),
                        onSave: () => unawaited(_toggleSave(featuredJob.id)),
                        onShare: () => _shareJob(featuredJob, locale),
                        statusColor: _contentCheckBadgeColor(
                          featuredVerification.status,
                        ),
                        verification: featuredVerification,
                        miniAnalysis: _miniAnalysisText(featuredVerification, locale),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (urgent.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: HomeSectionHeader(
                    overline: JobsStrings.t('jobs_tab_urgent', locale),
                    title: JobsStrings.t('jobs_hiring_now', locale),
                    leadingIcon: Icons.local_fire_department_outlined,
                  ),
                ),
              ),
            if (urgent.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: urgent.map((job) {
                      final verification = getJobVerification(job, locale);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _UrgentJobCard(
                          job: job,
                          locale: locale,
                          verification: verification,
                          isSaved: isJobSaved(job.id),
                          onTap: () => _applyToJob(job, verification),
                          onSave: () => unawaited(_toggleSave(job.id)),
                          onShare: () => _shareJob(job, locale),
                          statusColor:
                              _contentCheckBadgeColor(verification.status),
                          badgeLabel: _badgeLabel(verification.status, locale),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (_spotlightCompany(allJobs) != null)
              SliverToBoxAdapter(child: _buildCompanySpotlight(allJobs, locale)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Text(
                  JobsStrings.t('jobs_tab_jobs', locale),
                  key: const Key('jobs_hub_tab_jobs_heading'),
                  style: AppTypography.title,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final profile = ref
                          .read(userProfileAIServiceProvider)
                          .getCachedProfile() ??
                      ref.watch(userAIProfileProvider);
                  if (profile == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandFamilyMain.withValues(alpha: 0.07),
                      border: Border.all(
                        color: AppColors.brandFamilyMain.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          JobsStrings.t('jobs_sorted_ai_match', locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.brandFamilyMain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (allJobs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: GlassEmptyState(
                      icon: Icons.work_off_outlined,
                      title: JobsStrings.t('jobs_no_jobs_posted_title', locale),
                      description: JobsStrings.t('jobs_no_jobs_posted_body', locale),
                      actionLabel: JobsStrings.t('jobs_no_jobs_posted_action', locale),
                      onAction: _showPostJobSheet,
                      accent: GlassEmptyStateAccent.brand,
                    ),
                  ),
                ),
              )
            else if (jobs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassEmptyState(
                          key: const Key('jobs_hub_empty_filter_state'),
                          icon: Icons.work_off_outlined,
                          title: JobsStrings.t(
                            'jobs_hub_empty_filter_title',
                            locale,
                          ),
                          description: JobsStrings.t(
                            'jobs_hub_empty_filter_body',
                            locale,
                          ),
                          accent: GlassEmptyStateAccent.brand,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SaveSearchButton(
                          key: const Key('jobs_hub_empty_save_search'),
                          vertical: SavedSearchVertical.jobs,
                          accent: SaveSearchButtonAccent.hubBrand,
                          criteria: SavedSearchCriteria.fromJobsBrowse(
                            query: _searchController.text,
                            selectedCategoryIndex: _selectedFilter,
                            routeFilters: _routeFilters,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final job = jobs[index];
                      final verification = getJobVerification(job, locale);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < jobs.length - 1 ? AppSpacing.md : 0,
                        ),
                        child: JobsHubMainListingCard(
                          job: job,
                          locale: locale,
                          linkedBusinessesById: linkedBusinessesById,
                          isSaved: isJobSaved(job.id),
                          onApply: () => _applyToJob(job, verification),
                          onSave: () => unawaited(_toggleSave(job.id)),
                          onShare: () => _shareJob(job, locale),
                        ),
                      );
                    },
                    childCount: jobs.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: JobsHubFeedFooterNotice(locale: locale),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildJobsLandingHeaderActions(BuildContext context, String locale) {
    final onBrand = Theme.of(context).colorScheme.onPrimary;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        TextButton(
          key: const Key('jobs_hub_view_applications'),
          onPressed: () => context.push('/jobs/my-applications'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandFamilyMain,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            JobsApplicationStrings.t(
              'jobs_app_view_applications',
              locale,
            ),
          ),
        ),
        TextButton.icon(
          key: const Key('jobs_hub_post_job_header'),
          onPressed: _showPostJobSheet,
          icon: const Icon(Icons.add, size: 18),
          label: Text(JobsStrings.t('jobs_post_job', locale)),
          style: TextButton.styleFrom(
            foregroundColor: onBrand,
            backgroundColor: AppColors.brandFamilyMain,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandingChrome(BuildContext context, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HubLandingHeader(
          key: const Key('jobs_hub_landing_header'),
          title: JobsStrings.t('jobs_hub_title', locale),
          subtitle: JobsStrings.t('jobs_hub_subtitle', locale),
          onBack: () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            0,
          ),
          child: Column(
            key: const Key('jobs_hub_landing_header_block'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _buildJobsLandingHeaderActions(context, locale),
              ),
              const SizedBox(height: AppSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HubLayoutTokens.searchMinHeight,
                ),
                child: TextField(
                  key: const Key('jobs_hub_search'),
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.subtitle,
                  textInputAction: TextInputAction.search,
                  decoration: hubSearchInputDecoration(
                    hintText: JobsStrings.t('jobs_search_hint', locale),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SaveSearchButton(
                  vertical: SavedSearchVertical.jobs,
                  accent: SaveSearchButtonAccent.hubBrand,
                  criteria: SavedSearchCriteria.fromJobsBrowse(
                    query: _searchController.text,
                    selectedCategoryIndex: _selectedFilter,
                    routeFilters: _routeFilters,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const double _kJobsQuickActionsFourColumnMinWidth = 400;

  Widget _buildQuickActionsRow(String locale) {
    final tiles = <({Key key, IconData icon, String label, VoidCallback onTap})>[
      (
        key: const Key('jobs_hub_qa_offer_calculator'),
        icon: Icons.calculate_outlined,
        label: JobsStrings.t('jobs_hub_qa_offer_calculator', locale),
        onTap: () => context.push(JobOfferCalculatorScreen.route()),
      ),
      (
        key: const Key('jobs_hub_qa_check_agency'),
        icon: Icons.verified_user_outlined,
        label: JobsStrings.t('jobs_hub_qa_check_agency', locale),
        onTap: () => context.push(AgencyVerificationScreen.route()),
      ),
      (
        key: const Key('jobs_hub_qa_employer_record'),
        icon: Icons.balance_outlined,
        label: JobsStrings.t('jobs_hub_qa_employer_record', locale),
        onTap: () => context.push(EmployerTrackRecordLookupScreen.route()),
      ),
      (
        key: const Key('jobs_hub_qa_my_cv'),
        icon: Icons.description_outlined,
        label: JobsStrings.t('jobs_hub_qa_my_cv', locale),
        onTap: () => context.push('/jobs/cv-start'),
      ),
    ];

    Widget tile(({Key key, IconData icon, String label, VoidCallback onTap}) spec) {
      return KeyedSubtree(
        key: spec.key,
        child: HubQuickActionTile(
          icon: spec.icon,
          label: spec.label,
          onTap: spec.onTap,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useFourColumns =
              constraints.maxWidth >= _kJobsQuickActionsFourColumnMinWidth;
          if (useFourColumns) {
            return Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(child: tile(tiles[i])),
                ],
              ],
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: tile(tiles[0])),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: tile(tiles[1])),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: tile(tiles[2])),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: tile(tiles[3])),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHubSummaryStrip(String locale) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return const SizedBox.shrink();

    final appsAsync = ref.watch(userJobApplicationsProvider(uid));
    final underReviewCount = appsAsync.maybeWhen(
      data: (apps) => apps
          .where((app) => app.status == JobApplicationStatus.underReview)
          .length,
      orElse: () => null,
    );

    final savedJobIds = ref.watch(
      userAIProfileProvider.select((p) => p?.savedJobIds ?? const []),
    );
    final savedJobsCount =
        JobsRepository.orderedUniqueSavedJobIds(savedJobIds).length;

    final cards = <Widget>[];

    if (underReviewCount != null && underReviewCount > 0) {
      final value = JobsApplicationStrings.format(
        'jobs_hub_summary_under_review_value',
        locale,
        params: {'count': ProfileDisplayHelper.formatCount(underReviewCount)},
      );
      final label =
          JobsApplicationStrings.t('jobs_hub_summary_applications_label', locale);

      cards.add(
        Expanded(
          child: HubSummaryStripCard(
            key: const Key('jobs_hub_applications_summary'),
            value: value,
            label: label,
            icon: Icons.description_outlined,
            onTap: () => context.push('/jobs/my-applications'),
          ),
        ),
      );
    }

    if (savedJobsCount > 0) {
      if (cards.isNotEmpty) {
        cards.add(const SizedBox(width: AppSpacing.sm));
      }
      final savedValue = JobsStrings.format(
        'jobs_hub_summary_saved_jobs_value',
        locale,
        params: {'count': ProfileDisplayHelper.formatCount(savedJobsCount)},
      );
      final savedLabel =
          JobsStrings.t('jobs_hub_summary_saved_jobs_label', locale);
      final savedSemanticsLabel = '$savedValue. $savedLabel';

      cards.add(
        Expanded(
          child: Semantics(
            button: true,
            label: savedSemanticsLabel,
            child: ExcludeSemantics(
              child: HubSummaryStripCard(
                key: const Key('jobs_hub_saved_jobs_summary'),
                value: savedValue,
                label: savedLabel,
                icon: Icons.favorite_outline,
                onTap: () => context.push('/jobs/saved'),
              ),
            ),
          ),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return HubSummaryStripPadding(child: Row(children: cards));
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          itemCount: kJobCategories.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final selected = _selectedFilter == index;
            return buildHubFilterChip(
              label: Text(kJobCategories[index]),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmployerSegmentChips(String locale) {
    const segments = JobsHubEmployerSegment.values;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          itemCount: segments.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final segment = segments[index];
            final selected = _employerSegment == segment;
            final labelKey = switch (segment) {
              JobsHubEmployerSegment.all => 'jobs_all_jobs',
              JobsHubEmployerSegment.verifiedEmployers =>
                'jobs_hub_segment_verified_employers',
              JobsHubEmployerSegment.communityPosts =>
                'jobs_hub_segment_community_posts',
            };
            return KeyedSubtree(
              key: Key('jobs_hub_employer_segment_${segment.name}'),
              child: buildHubFilterChip(
                label: Text(JobsStrings.t(labelKey, locale)),
                selected: selected,
                onSelected: (_) => setState(() => _employerSegment = segment),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiMatchBanner(List<JobListing> allJobs, String locale) {
    final profile = ref.read(userAIProfileProvider);
    final matched = _matchedJobCount(allJobs);

    final value = profile == null
        ? '—'
        : ProfileDisplayHelper.formatCount(matched);
    final label = profile == null
        ? JobsStrings.t('jobs_complete_profile_matches', locale)
        : JobsStrings.format(
            'jobs_profile_match_today',
            locale,
            params: {'count': '$matched'},
          );
    final semanticsLabel =
        '${JobsStrings.t('jobs_ai_match_score', locale)}. $label. '
        '${JobsStrings.t('jobs_update_profile_cta', locale)}';

    return HubSummaryStripPadding(
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: HubSummaryStripCard(
            key: const Key('jobs_hub_ai_match_summary'),
            value: value,
            label: label,
            icon: Icons.auto_awesome_outlined,
            onTap: () => context.push('/profile'),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySpotlight(List<JobListing> allJobs, String locale) {
    final spotlight = _spotlightCompany(allJobs);
    if (spotlight == null) return const SizedBox.shrink();
    final initial =
        spotlight.company.isNotEmpty ? spotlight.company[0].toUpperCase() : '?';
    final companyJobs =
        allJobs.where((j) => j.company == spotlight.company).toList();
    final benefits = companyJobs
        .expand((j) => j.benefits)
        .toSet()
        .take(4)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const Key('jobs_hub_company_spotlight_heading'),
            children: [
              Icon(
                RaabtaIcons.forRoute('/businesses'),
                size: AppSpacing.iconMd,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  JobsStrings.t('jobs_company_spotlight', locale),
                  style: AppTypography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            JobsStrings.t('jobs_company_spotlight_discovery', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            key: const Key('jobs_hub_company_spotlight_card'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppSpacing.radiusLg,
            glowColor: AppColors.brandFamilyMain,
            glowIntensity: 0.06,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.surfaceElevated,
                      child: Text(
                        initial,
                        style: AppTypography.headline2.copyWith(
                          color: AppColors.brandFamilyMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spotlight.company, style: AppTypography.title),
                          Text(spotlight.industry, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  JobsStrings.format(
                    spotlight.count == 1
                        ? 'jobs_hiring_open_role'
                        : 'jobs_hiring_open_roles',
                    locale,
                    params: {'count': '${spotlight.count}'},
                  ),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (benefits.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: benefits
                        .map(
                          (b) => _BenefitChip(
                            icon: ServiceScreenIcons.jobBenefit(b),
                            label: JobsStrings.benefitLabel(b, locale),
                          ),
                        )
                        .toList(),
                  ),
                if (benefits.isNotEmpty) const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _searchController.text = spotlight.company);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandFamilyMain,
                      side: BorderSide(
                        color: AppColors.brandFamilyMain.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(JobsStrings.t('jobs_view_all_jobs', locale)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumJobCard extends StatelessWidget {
  const _PremiumJobCard({
    required this.job,
    required this.locale,
    required this.badge,
    required this.isSaved,
    required this.onApply,
    required this.onSave,
    required this.onShare,
    required this.statusColor,
    required this.verification,
    required this.miniAnalysis,
  });

  final JobListing job;
  final String locale;
  final PremiumJobBadge badge;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final Color statusColor;
  final JobVerificationResult verification;
  final String miniAnalysis;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.background,
                child: Text(
                  job.companyInitial,
                  style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.company,
                      style: AppTypography.subtitle.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(job.industry, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              _MonetizationBadge(type: badge, locale: locale),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(job.title, style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            job.salary,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.cyanGlow,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('📍 ${job.location}', style: AppTypography.bodySmall),
          if (job.benefits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _BenefitRow(benefits: job.benefits, locale: locale),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            JobsStrings.format(
              'jobs_posted_applicants',
              locale,
              params: {'posted': job.posted, 'count': '${job.applicants}'},
            ),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cyanGlow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    JobsStrings.t(_jobsHubPrimaryCtaKey(job), locale),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? AppColors.cyanGlow : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: onShare,
                icon: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _AiMiniBox(text: miniAnalysis, borderColor: statusColor),
        ],
      ),
    );
  }
}

class _UrgentJobCard extends StatelessWidget {
  const _UrgentJobCard({
    required this.job,
    required this.locale,
    required this.verification,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
    required this.onShare,
    required this.statusColor,
    required this.badgeLabel,
  });

  final JobListing job;
  final String locale;
  final JobVerificationResult verification;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final Color statusColor;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusSm,
      glowColor: AppColors.error,
      glowIntensity: 0.1,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MonetizationBadge(
                  type: PremiumJobBadge.urgent,
                  locale: locale,
                ),
                const Spacer(),
                StatusBadge(label: badgeLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              job.title,
              style: AppTypography.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              job.company,
              style: AppTypography.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              job.location,
              style: AppTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              job.salary,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    JobsStrings.format(
                      'jobs_posted_applicants',
                      locale,
                      params: {'posted': job.posted, 'count': '${job.applicants}'},
                    ),
                    style: AppTypography.bodySmall,
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? AppColors.cyanGlow : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onShare,
                  icon: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _MonetizationBadge extends StatelessWidget {
  const _MonetizationBadge({required this.type, required this.locale});

  final PremiumJobBadge type;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      PremiumJobBadge.featured => (
          JobsStrings.t('jobs_badge_featured', locale),
          AppColors.amberGlow,
        ),
      PremiumJobBadge.urgent => (
          JobsStrings.t('jobs_badge_urgent_label', locale),
          AppColors.error,
        ),
      PremiumJobBadge.spotlight => (
          JobsStrings.t('jobs_badge_spotlight', locale),
          AppColors.purpleGlow,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefits, required this.locale});

  final List<String> benefits;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: benefits.map((benefit) {
        return _BenefitChip(
          icon: ServiceScreenIcons.jobBenefit(benefit),
          label: JobsStrings.benefitLabel(benefit, locale),
        );
      }).toList(),
    );
  }
}

class _AiMiniBox extends StatelessWidget {
  const _AiMiniBox({required this.text, required this.borderColor});

  final String text;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: borderColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textOnGlassSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
