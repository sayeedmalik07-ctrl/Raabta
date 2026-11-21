import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Resolved saved jobs for the current profile order.
class SavedJobsResolution {
  const SavedJobsResolution({
    required this.savedIds,
    required this.listings,
  });

  final List<String> savedIds;
  final List<JobListing> listings;

  bool get hasSavedIds => savedIds.isNotEmpty;

  bool get allUnavailable => hasSavedIds && listings.isEmpty;
}

class SavedJobsListingsNotifier extends AsyncNotifier<SavedJobsResolution> {
  bool _refreshInFlight = false;

  @override
  Future<SavedJobsResolution> build() async {
    return _load();
  }

  Future<SavedJobsResolution> _load() async {
    final savedIds = ref.watch(
      userAIProfileProvider.select((p) => p?.savedJobIds ?? const []),
    );
    if (savedIds.isEmpty) {
      return const SavedJobsResolution(savedIds: [], listings: []);
    }

    final repo = ref.read(jobsRepositoryProvider);
    final activeById = await repo.fetchActiveJobsByIds(savedIds);
    final listings = JobsRepository.orderActiveSavedJobs(
      savedJobIds: savedIds,
      activeById: activeById,
    );
    return SavedJobsResolution(savedIds: savedIds, listings: listings);
  }

  Future<void> refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      state = const AsyncValue<SavedJobsResolution>.loading().copyWithPrevious(
        state,
        isRefresh: true,
      );
      state = await AsyncValue.guard(_load);
    } finally {
      _refreshInFlight = false;
    }
  }
}

final savedJobListingsProvider =
    AsyncNotifierProvider<SavedJobsListingsNotifier, SavedJobsResolution>(
  SavedJobsListingsNotifier.new,
);
