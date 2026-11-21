import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_response.dart';
import 'package:raabta/features/global_search/domain/search_coverage_checker.dart';

/// Validates and sanitizes AI responses before display (S9).
abstract final class SearchAskAiResponseValidator {
  static const maxOutputLength = 4000;

  static const _allowedActionNames = {
    'verifyEmployer',
    'verifyAgency',
    'calculateEosb',
    'scanDocument',
    'convertCurrency',
  };

  static const _extraAllowedRoutes = {
    '/visa',
    '/jobs',
    '/housing',
    '/services',
    '/eosb',
    '/money-services/corridor-comparator',
    '/scanner',
    '/scanner/capture',
    '/document-vault',
    '/community',
    '/health-insurance',
    '/trip-planner',
    '/prayer-mosque',
  };

  static SearchAskAiResponse validate({
    required String rawAnswer,
    List<String>? rawActions,
    List<String>? rawDestinations,
    bool fromFallback = false,
    String? errorMessage,
  }) {
    if (errorMessage != null && errorMessage.trim().isNotEmpty) {
      return SearchAskAiResponse(
        answer: '',
        errorMessage: errorMessage.trim(),
        fromFallback: fromFallback,
      );
    }

    final answer = _sanitizeAnswer(rawAnswer);
    if (answer.isEmpty) {
      return const SearchAskAiResponse(
        answer: '',
        errorMessage: 'empty_response',
      );
    }

    return SearchAskAiResponse(
      answer: answer,
      suggestedActions: _validateActions(rawActions ?? const []),
      suggestedDestinations: _validateDestinations(rawDestinations ?? const []),
      disclaimerRequired: true,
      fromFallback: fromFallback,
    );
  }

  static String _sanitizeAnswer(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return '';

    // Strip HTML-like tags.
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Reject javascript/data URLs embedded in text.
    text = text.replaceAll(
      RegExp(r'(javascript:|data:text/html)', caseSensitive: false),
      '',
    );

    if (text.length > maxOutputLength) {
      text = '${text.substring(0, maxOutputLength).trim()}…';
    }
    return text;
  }

  static List<SearchActionId> _validateActions(List<String> raw) {
    final validated = <SearchActionId>[];
    for (final name in raw) {
      if (!_allowedActionNames.contains(name)) continue;
      SearchActionId? id;
      for (final candidate in SearchActionId.values) {
        if (candidate.name == name) {
          id = candidate;
          break;
        }
      }
      if (id != null && !validated.contains(id)) {
        validated.add(id);
      }
    }
    return validated;
  }

  static List<String> _validateDestinations(List<String> raw) {
    final allowed = {
      ...SearchCoverageChecker.expectedSearchableRoutes,
      ..._extraAllowedRoutes,
    };
    final validated = <String>[];
    for (final route in raw) {
      final trimmed = route.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains('://')) continue;
      if (trimmed.startsWith('http')) continue;

      final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      final isAllowed = allowed.any(
        (prefix) =>
            normalized == prefix || normalized.startsWith('$prefix/'),
      );
      if (isAllowed && !validated.contains(normalized)) {
        validated.add(normalized);
      }
    }
    return validated;
  }
}
