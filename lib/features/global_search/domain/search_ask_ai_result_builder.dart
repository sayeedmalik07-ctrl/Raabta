import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/data/search_recent_query_repository.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_eligibility.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';

/// Builds the ASK AI offer card — deterministic, no network (S9).
abstract final class SearchAskAiResultBuilder {
  static SearchAskAiResult? build({
    required SearchAnalysis analysis,
    required GlobalSearchResponse response,
    required String locale,
    required bool isOnline,
  }) {
    final eligibility = SearchAskAiEligibility.evaluate(
      analysis: analysis,
      response: response,
      isOnline: isOnline,
      isSensitiveQuery:
          SearchRecentQueryRepository.isSensitiveQuery(analysis.originalQuery),
    );

    if (!eligibility.isEligible) return null;

    return SearchAskAiResult(
      displayTitle: AppShellStrings.t('global_search_ask_ai', locale),
      displaySubtitle: AppShellStrings.t('global_search_ask_ai_subtitle', locale),
      originalQuery: analysis.originalQuery.trim(),
      reason: eligibility.reason,
    );
  }
}
