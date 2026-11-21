import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/data/models/job_application_lifecycle.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/screens/jobs/widgets/job_application_status_badge.dart';

class JobListingApplicationsScreen extends ConsumerWidget {
  const JobListingApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  final String jobId;
  final String jobTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final appsAsync = ref.watch(jobListingApplicationsProvider(jobId));

    return GlassScreenScaffold(
      title: JobsApplicationStrings.t('jobs_app_manage_candidates', locale),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(jobTitle, style: AppTypography.subtitle),
          ),
          Expanded(
            child: appsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.purpleGlow),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (apps) {
                if (apps.isEmpty) {
                  return Center(
                    child: Text(
                      JobsApplicationStrings.t('jobs_app_manage_empty', locale),
                      style: AppTypography.body,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: apps.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _CandidateCard(
                    application: apps[index],
                    locale: locale,
                    jobId: jobId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends ConsumerWidget {
  const _CandidateCard({
    required this.application,
    required this.locale,
    required this.jobId,
  });

  final JobApplication application;
  final String locale;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextStatuses = JobApplicationStatus.values
        .where(
          (status) =>
              JobApplicationLifecycle.canEmployerSet(application.status, status),
        )
        .toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.applicantUid,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          JobApplicationStatusBadge(status: application.status, locale: locale),
          if (nextStatuses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              JobsApplicationStrings.t('jobs_app_update_status', locale),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final status in nextStatuses)
                  GlassPrimaryButton(
                    label: JobsApplicationStrings.t(status.labelKey(), locale),
                    onPressed: () => _updateStatus(context, ref, status),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(
              '/jobs/chat/$jobId/${application.applicantUid}',
              extra: application.jobTitle,
            ),
            child: Text(JobsApplicationStrings.t('jobs_app_view_thread', locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    JobApplicationStatus status,
  ) async {
    try {
      await ref.read(jobsRepositoryProvider).updateApplicationStatus(
            application: application,
            nextStatus: status,
            locale: locale,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }
}
