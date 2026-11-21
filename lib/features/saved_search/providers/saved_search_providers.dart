import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/saved_search/data/saved_search_repository.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/services/saved_search_match_client.dart';
import 'package:raabta/providers/auth_providers.dart';

final savedSearchRepositoryProvider = Provider<SavedSearchRepository>((ref) {
  return SavedSearchRepository();
});

final savedSearchMatchClientProvider = Provider<SavedSearchMatchClient>((ref) {
  return SavedSearchMatchClient();
});

final userSavedSearchesProvider = StreamProvider<List<SavedSearch>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid ?? '';
  if (uid.isEmpty) return Stream.value(const []);
  return ref.watch(savedSearchRepositoryProvider).watchUserSavedSearches(uid);
});

final userSavedSearchesForVerticalProvider =
    StreamProvider.family<List<SavedSearch>, SavedSearchVertical>((ref, vertical) {
  final uid = ref.watch(currentUserProvider)?.uid ?? '';
  if (uid.isEmpty) return Stream.value(const []);
  return ref
      .watch(savedSearchRepositoryProvider)
      .watchUserSavedSearchesForVertical(uid, vertical);
});
