import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/data/scam_advisory_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_matcher.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';

final scamAdvisoryRepositoryProvider = Provider<ScamAdvisoryRepository>((ref) {
  return ScamAdvisoryRepository();
});

/// Active published advisories — one cached Firestore read per TTL window.
final scamActiveAdvisoriesProvider =
    FutureProvider<List<ScamAdvisory>>((ref) async {
  return ref.watch(scamAdvisoryRepositoryProvider).loadActiveAdvisories();
});

/// In-memory catalog for Phase 12 evidence merge (empty until first fetch).
final scamAdvisoryCatalogProvider = Provider<List<ScamAdvisory>>((ref) {
  return ref.watch(scamActiveAdvisoriesProvider).valueOrNull ?? const [];
});

class ScamAdvisoryMatchInput {
  const ScamAdvisoryMatchInput({
    required this.text,
    required this.locale,
    this.claimedEntityIds = const [],
  });

  final String text;
  final String locale;
  final List<String> claimedEntityIds;
}

/// Deterministic advisory matches for scan text — Phase 12 consumes this.
final scamAdvisoryMatchesProvider =
    Provider.family<List<ScamAdvisoryMatch>, ScamAdvisoryMatchInput>((ref, input) {
  final advisories = ref.watch(scamAdvisoryCatalogProvider);
  var claimed = input.claimedEntityIds;
  if (claimed.isEmpty) {
    claimed = OfficialDirectory.detectClaimedEntity(input.text, input.locale)
        .matches;
  }
  return ScamAdvisoryMatcher.match(
    text: input.text,
    claimedEntityIds: claimed,
    locale: input.locale,
    activeAdvisories: advisories,
  );
});

final scamAdvisorySeenIdsProvider = FutureProvider<Set<String>>((ref) async {
  return ref.watch(scamAdvisoryRepositoryProvider).loadSeenIds();
});
