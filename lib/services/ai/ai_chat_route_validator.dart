import 'package:raabta/data/raabta_feature_navigation_guide.dart';
import 'package:raabta/features/global_search/domain/search_coverage_checker.dart';
import 'package:raabta/services/ai/ai_chat_allowed_route_roots.dart';

/// Allowlisted in-app routes for AI-suggested navigation actions.
abstract final class AiChatRouteValidator {
  static const _blockedPrefixes = {
    'http://',
    'https://',
    'javascript:',
    'data:',
    '//',
  };

  static Set<String> get _allowedRoutes => {
        ...AiChatAllowedRouteRoots.userFacing,
        ...SearchCoverageChecker.expectedSearchableRoutes,
        ...RaabtaFeatureNavigationGuide.actionRouteRoots,
      };

  /// Returns a safe GoRouter path or null if the route must be rejected.
  static String? validate(String rawRoute) {
    final trimmed = rawRoute.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    for (final blocked in _blockedPrefixes) {
      if (lower.startsWith(blocked)) return null;
    }
    if (trimmed.contains('://')) return null;
    if (trimmed.contains('..')) return null;

    var normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    normalized = normalized.split('#').first.split('?').first;
    if (normalized.length > 256) return null;
    if (!RegExp(r'^/[a-zA-Z0-9/_\-]+$').hasMatch(normalized)) return null;

    final allowed = _allowedRoutes;

    final isAllowed = allowed.any(
      (prefix) => normalized == prefix || normalized.startsWith('$prefix/'),
    );
    return isAllowed ? normalized : null;
  }
}
