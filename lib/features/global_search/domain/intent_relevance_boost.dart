import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Bounded deterministic boost when a result category aligns with query intent.
abstract final class IntentRelevanceBoost {
  static const maxBoost = 25;

  static int forCategory(GlobalSearchCategory category, SearchAnalysis analysis) {
    if (analysis.intent == SearchIntent.unknown || analysis.confidence <= 0) {
      return 0;
    }
    if (!_alignedCategories(analysis).contains(category)) return 0;
    return (analysis.confidence * maxBoost).round().clamp(0, maxBoost);
  }

  static Set<GlobalSearchCategory> _alignedCategories(SearchAnalysis analysis) {
    switch (analysis.intent) {
      case SearchIntent.findJob:
        return {GlobalSearchCategory.jobs};
      case SearchIntent.findHousing:
        return {GlobalSearchCategory.housing};
      case SearchIntent.findBusiness:
        return {GlobalSearchCategory.businesses};
      case SearchIntent.findService:
        return {GlobalSearchCategory.services};
      case SearchIntent.findDoctor:
        return {GlobalSearchCategory.health};
      case SearchIntent.checkRate:
        return {
          GlobalSearchCategory.money,
          GlobalSearchCategory.exchange,
        };
      case SearchIntent.visaQuestion:
        return {GlobalSearchCategory.visa};
      case SearchIntent.communityQuestion:
        return {GlobalSearchCategory.community};
      case SearchIntent.eosbCalculator:
        return {GlobalSearchCategory.tools};
      case SearchIntent.prayerMosque:
        return {GlobalSearchCategory.mosques};
      case SearchIntent.tripPlanner:
        return {GlobalSearchCategory.tripPlanner};
      case SearchIntent.verifyEmployer:
      case SearchIntent.verifyAgency:
      case SearchIntent.scanDocument:
        return const {};
      case SearchIntent.unknown:
        return const {};
    }
  }
}
