import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/features/global_search/domain/global_search_provider.dart';

/// Dev/admin check: surfaces GoRouter paths with no registered search provider.
abstract final class SearchCoverageChecker {
  /// Top-level routes expected to be searchable in Global Search.
  /// Excludes auth, splash, admin-only, and non-content screens.
  static const _baseExpectedSearchableRoutes = [
    '/jobs',
    '/housing',
    '/businesses',
    '/services',
    '/community',
    '/visa',
    '/money',
    '/money-services/gold',
    '/health-insurance',
    '/marketplace',
    '/document-vault',
    '/scanner',
    '/scanner/capture',
    '/trip-planner',
    '/prayer-mosque',
    '/eosb',
    '/ramadan',
    '/driving',
    '/bill-splitter',
    '/premium',
  ];

  static List<String> get expectedSearchableRoutes {
    if (MonetizationState.showPremiumTierUi) {
      return _baseExpectedSearchableRoutes;
    }
    return _baseExpectedSearchableRoutes
        .where((r) => !MonetizationState.isPremiumTierRoute(r))
        .toList();
  }

  /// Routes intentionally excluded from search (not meaningful content).
  static const excludedRoutes = [
    '/splash',
    '/login',
    '/language',
    '/onboarding/welcome',
    '/onboarding/qualifier',
    '/maintenance',
    '/force-update',
    '/suspended',
    '/feature-disabled',
    '/admin',
    '/global-search',
    '/notifications',
    '/notification-preferences',
    '/appearance',
    '/ai-chat',
  ];

  /// Returns routes from [expectedSearchableRoutes] with no provider coverage.
  static List<String> findUncoveredRoutes(
    Iterable<GlobalSearchProvider> providers,
  ) {
    final covered = <String>{};
    for (final p in providers) {
      covered.addAll(p.coveredRoutePrefixes);
    }

    return expectedSearchableRoutes
        .where((route) => !_isCovered(route, covered))
        .toList();
  }

  static bool _isCovered(String route, Set<String> prefixes) {
    for (final prefix in prefixes) {
      if (route == prefix || route.startsWith('$prefix/')) return true;
      if (prefix.startsWith(route)) return true;
    }
    return false;
  }

  static bool get isFullyCovered =>
      findUncoveredRoutes(GlobalSearchProviderRegistry.providers).isEmpty;
}
