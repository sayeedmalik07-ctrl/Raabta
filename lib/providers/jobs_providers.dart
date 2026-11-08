import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/data/models/job_application_chat_message.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/data/repositories/job_application_chat_repository.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/saved_jobs_providers.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository();
});

final jobsCatalogProvider = StreamProvider<List<JobListing>>((ref) {
  return ref.watch(jobsRepositoryProvider).watchActiveJobs();
});

@visibleForTesting
List<String> sortedUniqueJobLinkedBusinessIds(List<JobListing> jobs) {
  final unique = <String>{};
  for (final job in jobs) {
    final id = job.businessId?.trim();
    if (id != null && id.isNotEmpty) unique.add(id);
  }
  final ordered = unique.toList()..sort();
  return ordered;
}

String _linkedBusinessIdsCacheKey(List<String> ids) => ids.join('\x1e');

final jobsLinkedBusinessIdsKeyProvider = Provider<String>((ref) {
  final jobs = ref.watch(jobsCatalogProvider).valueOrNull;
  if (jobs == null) return '';
  return _linkedBusinessIdsCacheKey(sortedUniqueJobLinkedBusinessIds(jobs));
});

final jobsLinkedBusinessesProvider =
    FutureProvider<Map<String, BusinessListing>>((ref) async {
  ref.watch(jobsLinkedBusinessIdsKeyProvider);
  final jobs = ref.watch(jobsCatalogProvider).valueOrNull ?? const [];
  final ids = sortedUniqueJobLinkedBusinessIds(jobs);
  if (ids.isEmpty) return const {};
  try {
    return await ref
        .read(businessesRepositoryProvider)
        .fetchBusinessesByIds(ids);
  } catch (_) {
    return const {};
  }
});

final savedJobsLinkedBusinessIdsKeyProvider = Provider<String>((ref) {
  final resolution = ref.watch(savedJobListingsProvider).valueOrNull;
  if (resolution == null) return '';
  return _linkedBusinessIdsCacheKey(
    sortedUniqueJobLinkedBusinessIds(resolution.listings),
  );
});

final savedJobsLinkedBusinessesProvider =
    FutureProvider<Map<String, BusinessListing>>((ref) async {
  ref.watch(savedJobsLinkedBusinessIdsKeyProvider);
  final resolution = ref.watch(savedJobListingsProvider).valueOrNull;
  final listings = resolution?.listings ?? const [];
  final ids = sortedUniqueJobLinkedBusinessIds(listings);
  if (ids.isEmpty) return const {};
  try {
    return await ref
        .read(businessesRepositoryProvider)
        .fetchBusinessesByIds(ids);
  } catch (_) {
    return const {};
  }
});

final jobListingForIdProvider = Provider.family<JobListing?, String>((ref, jobId) {
  final jobs = ref.watch(jobsCatalogProvider).valueOrNull;
  if (jobs == null) return null;
  for (final job in jobs) {
    if (job.id == jobId) return job;
  }
  return null;
});

final jobApplicationChatRepositoryProvider =
    Provider<JobApplicationChatRepository>(
  (ref) => JobApplicationChatRepository(),
);

final userJobApplicationsProvider =
    StreamProvider.family<List<JobApplication>, String>((ref, uid) {
  return ref.watch(jobsRepositoryProvider).watchUserApplications(uid);
});

final userJobApplicationForJobProvider = StreamProvider.family<
    JobApplication?,
    ({String uid, String jobId})>((ref, params) {
  return ref.watch(jobsRepositoryProvider).watchUserApplicationForJob(
        uid: params.uid,
        jobId: params.jobId,
      );
});

final jobListingApplicationsProvider =
    StreamProvider.family<List<JobApplication>, String>((ref, jobId) {
  return ref.watch(jobsRepositoryProvider).watchJobApplications(jobId);
});

typedef JobApplicationChatParams = ({String jobId, String applicantUid});

final jobApplicationChatMessagesProvider = StreamProvider.family<
    List<JobApplicationChatMessage>,
    JobApplicationChatParams>((ref, params) {
  return ref.watch(jobApplicationChatRepositoryProvider).watchMessages(
        jobId: params.jobId,
        applicantUid: params.applicantUid,
      );
});

int? jobMaxSalaryValue(JobListing job) {
  final matches = RegExp(r'([\d,]+)').allMatches(job.salary);
  if (matches.isEmpty) return null;
  final values = matches
      .map((m) => int.tryParse(m.group(1)!.replaceAll(',', '')))
      .whereType<int>()
      .toList();
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a > b ? a : b);
}

List<JobListing> filterJobs({
  required List<JobListing> source,
  required String query,
  String? categoryFilter,
  String? area,
  int? minSalary,
  int? maxSalary,
  String? jobCategory,
  String? jobQuery,
}) {
  var jobs = source;
  if (query.isNotEmpty) {
    jobs = jobs.where((j) => j.searchableText.contains(query)).toList();
  }
  if (categoryFilter != null && categoryFilter != 'All') {
    jobs = jobs.where((j) => j.category == categoryFilter).toList();
  }
  if (area != null && area.trim().isNotEmpty) {
    final normalized = area.trim().toLowerCase();
    jobs = jobs
        .where((j) => j.location.toLowerCase().contains(normalized))
        .toList();
  }
  if (minSalary != null && minSalary > 0) {
    jobs = jobs.where((j) {
      final salary = jobMaxSalaryValue(j);
      return salary != null && salary >= minSalary;
    }).toList();
  }
  if (maxSalary != null && maxSalary > 0) {
    jobs = jobs.where((j) {
      final salary = jobMaxSalaryValue(j);
      return salary == null || salary <= maxSalary;
    }).toList();
  }
  if (jobCategory != null && jobCategory.trim().isNotEmpty) {
    final normalized = jobCategory.trim().toLowerCase();
    jobs = jobs
        .where(
          (j) =>
              j.category.toLowerCase() == normalized ||
              j.title.toLowerCase().contains(normalized) ||
              j.searchableText.contains(normalized),
        )
        .toList();
  }
  if (jobQuery != null && jobQuery.trim().isNotEmpty) {
    final normalized = jobQuery.trim().toLowerCase();
    jobs = jobs.where((j) => j.searchableText.contains(normalized)).toList();
  }
  return jobs;
}
