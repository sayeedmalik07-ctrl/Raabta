import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/instant_answer.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Pure deterministic resolver — no I/O, no providers, no network.
abstract final class InstantAnswerResolver {
  static InstantAnswer? resolve(InstantAnswerContext context) {
    if (!_baseEligible(context)) return null;

    return _tryNearestService(context) ??
        _tryDocumentIdentity(context) ??
        _tryCurrencyIntent(context) ??
        _tryMatchSummary(context);
  }

  static bool _baseEligible(InstantAnswerContext context) {
    final trimmed = context.currentQuery.trim();
    if (trimmed.isEmpty) return false;
    if (context.response.query != trimmed) return false;
    if (context.response.offline) return false;
    final analysis = context.analysis;
    if (analysis == null) return false;
    return true;
  }

  static InstantAnswer? _tryNearestService(InstantAnswerContext context) {
    final analysis = context.analysis!;
    if (!analysis.nearMe || context.response.locationUnavailable) return null;

    final services = _serviceItemsWithDistance(context.response);
    if (services.isEmpty) return null;

    services.sort((a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
    final item = services.first;
    final distance = item.distanceMeters;
    if (distance == null || distance < 0) return null;

    final trade = analysis.serviceTrade?.trim();
    final primaryKey = trade != null && trade.isNotEmpty
        ? 'global_search_instant_answer_nearby_service'
        : 'global_search_instant_answer_nearest_service_title';

    final primaryParams = trade != null && trade.isNotEmpty
        ? {'service': trade}
        : {'title': item.title};

    final bestMatch = context.response.bestMatch;
    final suppressBestMatch =
        bestMatch != null && bestMatch.result.id == item.id;

    return InstantAnswer(
      type: InstantAnswerType.nearestService,
      primaryLineKey: primaryKey,
      primaryLineParams: primaryParams,
      supportingLineKey: 'global_search_instant_answer_nearest_service_detail',
      supportingLineParams: {
        'title': item.title,
        'distance': '$distance',
      },
      actionItem: item,
      actionLabelKey: 'global_search_instant_answer_open_result',
      suppressBestMatch: suppressBestMatch,
    );
  }

  static List<GlobalSearchResultItem> _serviceItemsWithDistance(
    GlobalSearchResponse response,
  ) {
    final items = <GlobalSearchResultItem>[];
    for (final group in response.groups) {
      if (group.failed || group.category != GlobalSearchCategory.services) {
        continue;
      }
      for (final item in group.items) {
        if (item.distanceMeters != null && item.distanceMeters! >= 0) {
          items.add(item);
        }
      }
    }
    final best = response.bestMatch;
    if (best != null &&
        best.result.category == GlobalSearchCategory.services &&
        best.result.distanceMeters != null &&
        !items.any((i) => i.id == best.result.id)) {
      items.add(best.result);
    }
    return items;
  }

  static InstantAnswer? _tryDocumentIdentity(InstantAnswerContext context) {
    if (!context.isSignedIn) return null;

    final group = _groupFor(context.response, GlobalSearchCategory.documents);
    if (group == null || group.failed || group.items.isEmpty) return null;

    final total = group.totalMatched > 0 ? group.totalMatched : group.items.length;
    if (total <= 0) return null;

    if (total == 1) {
      final doc = group.items.first;
      final category = doc.subtitle.trim();
      final bestMatch = context.response.bestMatch;
      final suppressBestMatch =
          bestMatch != null && bestMatch.result.id == doc.id;

      if (category.isNotEmpty && category != 'Document Vault') {
        return InstantAnswer(
          type: InstantAnswerType.documentIdentity,
          primaryLineKey: 'global_search_instant_answer_document_title',
          primaryLineParams: {'title': doc.title},
          supportingLineKey: 'global_search_instant_answer_document_category',
          supportingLineParams: {'category': category},
          actionItem: doc,
          actionLabelKey: 'global_search_instant_answer_open_document',
          suppressBestMatch: suppressBestMatch,
        );
      }

      return InstantAnswer(
        type: InstantAnswerType.documentIdentity,
        primaryLineKey: 'global_search_instant_answer_document_title',
        primaryLineParams: {'title': doc.title},
        actionItem: doc,
        actionLabelKey: 'global_search_instant_answer_open_document',
        suppressBestMatch: suppressBestMatch,
      );
    }

    final first = group.items.first;
    final typeLabel = first.subtitle.trim();
    final countKey = typeLabel.isNotEmpty && typeLabel != 'Document Vault'
        ? 'global_search_instant_answer_document_typed_count'
        : 'global_search_instant_answer_document_count';

    final countParams = typeLabel.isNotEmpty && typeLabel != 'Document Vault'
        ? {'count': '$total', 'type': typeLabel}
        : {'count': '$total'};

    return InstantAnswer(
      type: InstantAnswerType.documentIdentity,
      primaryLineKey: countKey,
      primaryLineParams: countParams,
      actionItem: first,
      actionLabelKey: 'global_search_instant_answer_view_documents',
    );
  }

  static InstantAnswer? _tryCurrencyIntent(InstantAnswerContext context) {
    final analysis = context.analysis!;
    final from = analysis.fromCurrency?.trim().toUpperCase();
    final to = analysis.toCurrency?.trim().toUpperCase();
    if (from == null || to == null || from.isEmpty || to.isEmpty) return null;

    final convertAction = context.response.actions.cast<GlobalSearchResultItem?>().firstWhere(
          (a) => a?.actionId == SearchActionId.convertCurrency,
          orElse: () => null,
        );
    if (convertAction == null) return null;

    if (analysis.intent != SearchIntent.checkRate &&
        analysis.conversionAmount == null &&
        from == to) {
      return null;
    }

    final amount = analysis.conversionAmount;
    final primaryKey = amount != null && amount > 0
        ? 'global_search_action_currency_amount_subtitle'
        : 'global_search_action_currency_pair_subtitle';

    final primaryParams = amount != null && amount > 0
        ? {
            'amount': _formatAmount(amount),
            'from': from,
            'to': to,
          }
        : {'from': from, 'to': to};

    return InstantAnswer(
      type: InstantAnswerType.currencyIntent,
      primaryLineKey: primaryKey,
      primaryLineParams: primaryParams,
      actionItem: convertAction,
      actionLabelKey: 'global_search_action_currency_title',
      duplicateActionId: SearchActionId.convertCurrency,
    );
  }

  static InstantAnswer? _tryMatchSummary(InstantAnswerContext context) {
    final analysis = context.analysis!;
    if (!_matchSummaryIntentAllowed(analysis.intent)) return null;

    final category = _categoryForIntent(analysis.intent);
    if (category == null) return null;

    final group = _groupFor(context.response, category);
    if (group == null || group.failed) return null;

    final count = group.totalMatched > 0 ? group.totalMatched : group.items.length;
    if (count <= 0) return null;

    final area = analysis.area?.trim();
    if (count == 1 && (area == null || area.isEmpty)) {
      return null;
    }

    final categoryKey = _categoryLabelKey(category);

    return InstantAnswer(
      type: InstantAnswerType.matchSummary,
      primaryLineKey: 'global_search_instant_answer_match_count',
      primaryLineParams: {
        'count': '$count',
        'category': categoryKey,
      },
      supportingLineKey:
          area != null && area.isNotEmpty
              ? 'global_search_instant_answer_match_in_area'
              : null,
      supportingLineParams:
          area != null && area.isNotEmpty ? {'area': area} : const {},
      actionItem: group.items.isNotEmpty ? group.items.first : null,
      actionLabelKey: 'global_search_instant_answer_view_category',
      actionLabelParams: {'category': categoryKey},
    );
  }

  static bool _matchSummaryIntentAllowed(SearchIntent intent) {
    return switch (intent) {
      SearchIntent.findJob ||
      SearchIntent.findHousing ||
      SearchIntent.findBusiness ||
      SearchIntent.findService =>
        true,
      SearchIntent.findDoctor ||
      SearchIntent.visaQuestion ||
      SearchIntent.communityQuestion ||
      SearchIntent.checkRate ||
      SearchIntent.verifyEmployer ||
      SearchIntent.verifyAgency ||
      SearchIntent.scanDocument ||
      SearchIntent.eosbCalculator ||
      SearchIntent.prayerMosque ||
      SearchIntent.tripPlanner ||
      SearchIntent.unknown =>
        false,
    };
  }

  static GlobalSearchCategory? _categoryForIntent(SearchIntent intent) {
    return switch (intent) {
      SearchIntent.findJob => GlobalSearchCategory.jobs,
      SearchIntent.findHousing => GlobalSearchCategory.housing,
      SearchIntent.findBusiness => GlobalSearchCategory.businesses,
      SearchIntent.findService => GlobalSearchCategory.services,
      _ => null,
    };
  }

  static String _categoryLabelKey(GlobalSearchCategory category) {
    return switch (category) {
      GlobalSearchCategory.jobs => 'global_search_category_jobs',
      GlobalSearchCategory.housing => 'global_search_category_housing',
      GlobalSearchCategory.businesses => 'global_search_category_businesses',
      GlobalSearchCategory.services => 'global_search_category_services',
      _ => 'global_search_category_jobs',
    };
  }

  static GlobalSearchCategoryGroup? _groupFor(
    GlobalSearchResponse response,
    GlobalSearchCategory category,
  ) {
    for (final group in response.groups) {
      if (group.category == category) return group;
    }
    return null;
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
