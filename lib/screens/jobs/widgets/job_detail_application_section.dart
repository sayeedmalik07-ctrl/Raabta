import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/screens/jobs/widgets/job_application_status_badge.dart';

class JobDetailApplicationSection extends ConsumerWidget {
  const JobDetailApplicationSection({
    super.key,
    required this.job,
    required this.locale,
  });

  final JobListing job;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!job.supportsApplicationTracking) {
      return const SizedBox.shrink();
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return const SizedBox.shrink();
    }

    final applicationAsync = ref.watch(
      userJobApplicationForJobProvider((uid: uid, jobId: job.id)),
    );

    return applicationAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _SubmitButton(job: job, locale: locale),
      data: (application) {
        if (application == null) {
          return _SubmitButton(job: job, locale: locale);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JobApplicationStatusBadge(status: application.status, locale: locale),
            if (application.status == JobApplicationStatus.closed) ...[
              const SizedBox(height: 8),
              Text(
                JobsApplicationStrings.t('jobs_app_closed_hint', locale),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(
                '/jobs/chat/${job.id}/${application.applicantUid}',
                extra: job.title,
              ),
              child: Text(JobsApplicationStrings.t('jobs_app_view_thread', locale)),
            ),
          ],
        );
      },
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.job, required this.locale});

  final JobListing job;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ForewarningSlot(
          momentId: ForewarningMomentId.jobApply,
          locale: locale,
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
        onPressed: () async {
          try {
            final cv = await ref.read(cvRepositoryProvider).loadLatest();
            await ref.read(jobsRepositoryProvider).submitApplication(
                  jobId: job.id,
                  jobTitle: job.title,
                  company: job.company,
                  cvDocumentId: cv?.id,
                  cvVaultDocumentId: cv?.vaultDocumentId,
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    cv == null
                        ? JobsStrings.t('jobs_application_no_cv', locale)
                        : JobsStrings.t('jobs_application_with_cv', locale),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${JobsStrings.t('jobs_submit_failed', locale)}: $e'),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.send_outlined),
        label: Text(JobsStrings.t('jobs_submit_application', locale)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purpleGlow,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
          ),
        ),
      ],
    );
  }
}
