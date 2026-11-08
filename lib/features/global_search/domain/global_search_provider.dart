import 'package:raabta/features/global_search/domain/global_search_dependencies.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';

/// Contract for a searchable feature module.
///
/// Register via [GlobalSearchProviderRegistry.register] in the feature's
/// search provider file — see `SEARCH_REGISTRATION.md`.
abstract class GlobalSearchProvider {
  /// Unique provider id (e.g. `jobs`, `visa_guides`).
  String get id;

  /// Result bucket shown in grouped UI.
  GlobalSearchCategory get category;

  /// Route prefixes this provider covers (for coverage checks).
  List<String> get coveredRoutePrefixes;

  /// Execute a bounded search for [query]. Must not throw — return empty/failed group instead.
  Future<GlobalSearchCategoryGroup> search({
    required String query,
    required GlobalSearchDependencies deps,
    String? userId,
  });
}

/// Central registry — aggregator iterates registered providers instead of a hardcoded list.
class GlobalSearchProviderRegistry {
  GlobalSearchProviderRegistry._();

  static final List<GlobalSearchProvider> _providers = [];
  static bool _bootstrapped = false;

  static List<GlobalSearchProvider> get providers =>
      List.unmodifiable(_providers);

  static void register(GlobalSearchProvider provider) {
    if (_providers.any((p) => p.id == provider.id)) return;
    _providers.add(provider);
  }

  static void resetForTests() {
    _providers.clear();
    _bootstrapped = false;
  }

  static bool get isBootstrapped => _bootstrapped;

  static void markBootstrapped() => _bootstrapped = true;
}
