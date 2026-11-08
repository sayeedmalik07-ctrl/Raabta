import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/ai/expat_score_recommendation_builder.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:raabta/services/ai/expat_score_recommendation_builder.dart'
    show ExpatScoreRecommendation;

const _cacheKey = 'expat_score_detail_recs_v2';
const _fpKey = 'expat_score_detail_recs_fp_v2';

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

List<ExpatScoreRecommendation> _fromImprovementActions(
  List<ScoreAction> actions,
) {
  return actions
      .take(3)
      .map(
        (action) => ExpatScoreRecommendation(
          action: action.title,
          points: action.pointsGain,
          duration: action.estimatedTime,
          routeTarget: action.routeTarget,
        ),
      )
      .toList();
}

/// Three template recommendations for the Expat Score detail screen — capped by
/// live score fingerprint like the home hero advice provider.
final expatScoreDetailRecommendationsProvider = FutureProvider.autoDispose
    .family<List<ExpatScoreRecommendation>, String>((ref, uid) async {
  final locale = ref.watch(userLanguageProvider);
  final score = ref.watch(expatLifeScoreProvider).score;
  final profile = ref.watch(userAIProfileProvider);
  final actions = ref.watch(expatImprovementActionsProvider);

  if (score == null || profile == null) {
    return _fromImprovementActions(actions);
  }

  final fingerprint = '${_scoreFingerprint(score)}|$locale';
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '${_cacheKey}_${uid}_$locale';
  final fpStoreKey = '${_fpKey}_${uid}_$locale';
  final cachedFingerprint = prefs.getString(fpStoreKey);

  if (cachedFingerprint == fingerprint) {
    final cachedList = prefs.getStringList('${cacheKey}_items') ?? const [];
    if (cachedList.isNotEmpty) {
      return cachedList
          .map((line) {
            final parts = line.split('\t');
            if (parts.length < 3) return null;
            return ExpatScoreRecommendation(
              action: parts[0],
              points: int.tryParse(parts[1]) ?? 5,
              duration: parts[2],
              routeTarget:
                  parts.length > 3 ? parts[3] : ExpatScoreRouteTarget.tool,
            );
          })
          .whereType<ExpatScoreRecommendation>()
          .toList();
    }
  }

  final recommendations = ExpatScoreRecommendationBuilder.buildDetailRecommendations(
    score: score,
    actions: actions,
    locale: locale,
  );

  if (recommendations.isNotEmpty) {
    await prefs.setString(fpStoreKey, fingerprint);
    await prefs.setStringList(
      '${cacheKey}_items',
      recommendations
          .map(
            (rec) =>
                '${rec.action}\t${rec.points}\t${rec.duration}\t${rec.routeTarget}',
          )
          .toList(),
    );
  }

  if (recommendations.isNotEmpty) return recommendations;
  return _fromImprovementActions(actions);
});
