import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/screens/jobs/widgets/job_application_status_badge.dart';

class JobMyApplicationsScreen extends ConsumerWidget {
  const JobMyApplicationsScreen({
    super.key,
    @visibleForTesting this.applicantUidOverride,
  });

  /// When set (tests only), skips [FirebaseAuth] lookup; production leaves null.
  @visibleForTesting
  final String? applicantUidOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final uid = applicantUidOverride != null
        ? applicantUidOverride!
        : (FirebaseAuth.instance.currentUser?.uid ?? '');
    final appsAsync = ref.watch(userJobApplicationsProvider(uid));

    return GlassScreenScaffold(
      title: JobsApplicationStrings.t('jobs_my_applications_title', locale),
      body: appsAsync.when(
        loading: () => const Center(
          child: HubLoadingPlaceholder(),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  JobsApplicationStrings.t(
                    'jobs_my_applications_load_error',
                    locale,
                  ),
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(userJobApplicationsProvider(uid)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandFamilyMain,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    JobsApplicationStrings.t(
                      'jobs_my_applications_retry',
                      locale,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GlassEmptyState(
                  title: JobsApplicationStrings.t(
                    'jobs_my_applications_empty_title',
                    locale,
                  ),
                  description: JobsApplicationStrings.t(
                    'jobs_my_applications_empty',
                    locale,
                  ),
                  icon: Icons.work_outline,
                  accent: GlassEmptyStateAccent.brand,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final app = apps[index];
              return _ApplicationCard(app: app, locale: locale);
            },
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.app, required this.locale});

  final JobApplication app;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(app.jobTitle, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(app.company, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          JobApplicationStatusBadge(status: app.status, locale: locale),
          if (app.status == JobApplicationStatus.closed) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              JobsApplicationStrings.t('jobs_app_closed_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () =>
                context.push('/jobs/chat/${app.jobId}/${app.applicantUid}'),
            child: Text(
              JobsApplicationStrings.t('jobs_app_view_thread', locale),
            ),
          ),
        ],
      ),
    );
  }
}
