import 'package:go_router/go_router.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';

/// Central safe URI construction for Global Search FIND destinations (S4).
abstract final class SearchRouteBuilder {
  static final _blockedPathPattern = RegExp(r'(\.\./|//|<|>)');

  /// Builds a path with encoded query parameters. Returns [basePath] when empty.
  static String build(String basePath, [SearchRouteParameters? parameters]) {
    final sanitizedBase = _sanitizeBasePath(basePath);
    if (parameters == null || parameters.isEmpty) return sanitizedBase;

    final baseUri = Uri.parse(
      sanitizedBase.startsWith('/') ? sanitizedBase : '/$sanitizedBase',
    );
    final merged = Map<String, String>.from(baseUri.queryParameters);
    merged.addAll(_sanitizeQueryMap(parameters.toQueryMap()));

    if (merged.isEmpty) {
      return baseUri.path;
    }

    return Uri(
      path: baseUri.path,
      queryParameters: merged,
    ).toString();
  }

  static String _sanitizeBasePath(String basePath) {
    final trimmed = basePath.trim();
    if (trimmed.isEmpty) return '/';
    final pathOnly = trimmed.split('?').first;
    if (_blockedPathPattern.hasMatch(pathOnly)) {
      return '/';
    }
    return pathOnly.startsWith('/') ? pathOnly : '/$pathOnly';
  }

  static Map<String, String> _sanitizeQueryMap(Map<String, String> raw) {
    final sanitized = <String, String>{};
    for (final entry in raw.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (key.isEmpty || value.isEmpty) continue;
      if (key.contains('&') || key.contains('=')) continue;
      if (_blockedPathPattern.hasMatch(value)) continue;
      sanitized[key] = value;
    }
    return sanitized;
  }

  /// Parses typed route parameters from a GoRouter location (deep links).
  static SearchRouteParameters? fromRouterState(GoRouterState state) {
    if (state.uri.queryParameters.isEmpty) return null;
    final params = SearchRouteParameters.fromQueryMap(state.uri.queryParameters);
    return params.isEmpty ? null : params;
  }

  /// Hub FIND routes that accept structured query parameters.
  static bool isStructuredHubRoute(String routePath) {
    final path = routePath.split('?').first;
    return const {
      '/jobs',
      '/housing',
      '/services',
      '/businesses',
      '/visa',
    }.contains(path);
  }
}
