import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_repository.dart';
import 'package:raabta/features/legal_sources/domain/models/legal_source.dart';

final legalSourcesRepositoryProvider = Provider<LegalSourcesRepository>((ref) {
  return LegalSourcesRepository();
});

final legalSourcesProvider = FutureProvider<List<LegalSource>>((ref) async {
  return ref.watch(legalSourcesRepositoryProvider).fetchAll();
});

/// User-facing "last legal update" — max verified date among current sources.
final lastLegalUpdateProvider = FutureProvider<DateTime>((ref) async {
  final repo = ref.watch(legalSourcesRepositoryProvider);
  final sources = await ref.watch(legalSourcesProvider.future);
  return repo.latestVerifiedFromList(sources);
});
