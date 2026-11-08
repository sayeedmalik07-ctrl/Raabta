import 'package:raabta/services/ai/claude_ai_service.dart';

import '../food_local_analyzer.dart';
import '../models/dietary_profile.dart';
import 'e_number_claude_fallback.dart';
import 'e_number_lookup_service.dart';
import 'food_inspector_routing_log.dart';

/// Orchestrates local product analysis with bundled E-number lookup and
/// rare Claude fallback for unrecognized codes.
class FoodInspectorAnalysisService {
  FoodInspectorAnalysisService({
    required ENumberLookupService eNumberLookup,
    required ENumberClaudeFallback claudeFallback,
  })  : _eNumberLookup = eNumberLookup,
        _claudeFallback = claudeFallback;

  final ENumberLookupService _eNumberLookup;
  final ENumberClaudeFallback _claudeFallback;

  Future<LocalFoodAnalysis> analyze({
    required Map<String, dynamic> product,
    required String language,
    DietaryProfile? profile,
  }) async {
    final ingredients = (
      product['ingredients_text'] ??
      product['ingredients_text_en'] ??
      ''
    ).toString();
    final ingredientsLower = ingredients.toLowerCase();

    final codes = _eNumberLookup.extractCodes(
      product: product,
      ingredientsLower: ingredientsLower,
    );

    var resolution = await _eNumberLookup.resolveAdditives(
      codes: codes,
      uiLanguage: language,
    );

    if (resolution.unknownCodes.isNotEmpty) {
      FoodInspectorRoutingLog.claudeFallback(
        codes: resolution.unknownCodes,
        reason: 'missing_from_bundled_and_shared_cache',
      );
      try {
        final decoded = await _claudeFallback.decodeUnknownCodes(
          codes: resolution.unknownCodes,
          uiLanguage: language,
        );
        await _eNumberLookup.persistFallbackEntries(
          entries: _claudeFallback.toReferenceEntries(decoded),
          language: language,
        );

        resolution = ENumberResolution(
          additives: [...resolution.additives, ...decoded].take(8).toList(),
          unknownCodes: const [],
          bundledHits: resolution.bundledHits,
          sharedCacheHits: resolution.sharedCacheHits,
        );
      } catch (_) {
        // Keep partial local results; unknown codes simply omitted.
      }
    }

    FoodInspectorRoutingLog.localHit(
      resolvedCount: resolution.additives.length,
      bundledCount: resolution.bundledHits,
      sharedCacheCount: resolution.sharedCacheHits,
      detail: resolution.unknownCodes.isEmpty
          ? null
          : 'unresolved=${resolution.unknownCodes.join(",")}',
    );

    return FoodLocalAnalyzer.analyze(
      product: product,
      language: language,
      profile: profile,
      resolvedAdditives: resolution.additives,
      useReferenceSummary: true,
    );
  }
}

final foodInspectorAnalysisServiceFactory =
    (ClaudeAIService claude, {ENumberLookupService? lookup}) {
  final eNumberLookup = lookup ?? ENumberLookupService();
  return FoodInspectorAnalysisService(
    eNumberLookup: eNumberLookup,
    claudeFallback: ENumberClaudeFallback(claude),
  );
};
