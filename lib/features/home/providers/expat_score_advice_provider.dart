import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/l10n/home_recommendation_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/expat_score_recommendation_builder.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _adviceCacheKey = 'expat_score_advice_cache_v2';
const _adviceFingerprintKey = 'expat_score_advice_fp_v2';

String _scoreFingerprint(ExpatLifeScore score) {
  return [
    score.total.round(),
    score.career.round(),
    score.housing.round(),
    score.financial.round(),
    score.community.round(),
    score.documentation.round(),
    score.health.round(),
    ...score.categoryMeta.entries.map(
      (entry) =>
          '${entry.key}:${entry.value.rawPoints.round()}:${entry.value.confidence.toStringAsFixed(2)}',
    ),
  ].join('|');
}

/// Template advice for the Expat Score hero insight — refreshed when live
/// breakdown or category evidence changes.
/// Reactive improvement actions — recomputed when locale or profile changes.
final expatImprovementActionsProvider = Provider<List<ScoreAction>>((ref) {
  final locale = ref.watch(userLanguageProvider);
  final profile = ref.watch(userAIProfileProvider);
  if (profile == null) return const [];
  return ref
      .read(expatLifeScoreServiceProvider)
      .getImprovementActions(profile, locale: locale);
});

final expatScoreAdviceProvider =
    FutureProvider.autoDispose.family<String, String>((ref, uid) async {
  final locale = ref.watch(userLanguageProvider);
  final score = ref.watch(expatLifeScoreProvider).score;
  final profile = ref.watch(userAIProfileProvider);
  final actions = ref.watch(expatImprovementActionsProvider);

  if (score == null || profile == null) {
    return HomeRecommendationStrings.t('advice_default_empty', locale);
  }

  final fingerprint = '${_scoreFingerprint(score)}|$locale';
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '${_adviceCacheKey}_${uid}_$locale';
  final fpKey = '${_adviceFingerprintKey}_${uid}_$locale';
  final cached = prefs.getString(cacheKey);
  final cachedFingerprint = prefs.getString(fpKey);

  if (cached != null &&
      cached.trim().isNotEmpty &&
      cachedFingerprint == fingerprint) {
    return cached;
  }

  final text = ExpatScoreRecommendationBuilder.buildHeroAdvice(
    score: score,
    actions: actions,
    locale: locale,
  );

  await prefs.setString(cacheKey, text);
  await prefs.setString(fpKey, fingerprint);
  return text;
});
