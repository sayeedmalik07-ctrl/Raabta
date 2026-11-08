import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/l10n/home_recommendation_strings.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

class ExpatScoreRecommendation {
  const ExpatScoreRecommendation({
    required this.action,
    required this.points,
    required this.duration,
    this.routeTarget = ExpatScoreRouteTarget.tool,
  });

  final String action;
  final int points;
  final String duration;
  final String routeTarget;
}

/// Deterministic Expat Score advice and recommendations — zero AI cost.
abstract final class ExpatScoreRecommendationBuilder {
  static String _categoryLabel(String key, String locale) {
    return switch (key) {
      'career' => AppShellStrings.t('score_category_career', locale),
      'housing' => AppShellStrings.t('score_category_housing', locale),
      'financial' => AppShellStrings.t('score_category_financial', locale),
      'community' => AppShellStrings.t('score_category_community', locale),
      'documentation' => AppShellStrings.t('score_category_documentation', locale),
      _ => key,
    };
  }

  static String buildHeroAdvice({
    required ExpatLifeScore score,
    required List<ScoreAction> actions,
    String locale = 'English',
  }) {
    final meta = score.categoryMeta;
    if (meta.isEmpty && actions.isEmpty) {
      return HomeRecommendationStrings.t('advice_unlock_profile', locale);
    }

    final riskCategory = _categoryWithRiskExplanation(meta);
    if (riskCategory != null) {
      final label = _categoryLabel(riskCategory, locale);
      final explanation = meta[riskCategory]!.changeExplanation!;
      return HomeRecommendationStrings.format(
        'advice_category_attention',
        locale,
        params: {'category': label, 'why': explanation.why},
      );
    }

    final mismatchCategory = _categoryWithLowConfidence(meta);
    if (mismatchCategory != null) {
      final label = _categoryLabel(mismatchCategory, locale);
      return HomeRecommendationStrings.format(
        'advice_low_confidence',
        locale,
        params: {'category': label},
      );
    }

    final lowest = _lowestScoringCategory(score, meta);
    if (lowest != null) {
      final label = _categoryLabel(lowest.key, locale);
      final categoryMeta = meta[lowest.key];
      if (categoryMeta?.insufficientData == true) {
        return HomeRecommendationStrings.format(
          'advice_add_signals',
          locale,
          params: {'category': label},
        );
      }
      final pct = ExpatScoreProfileHelper.normalizeCategoryPercent(
        lowest.value,
        lowest.key,
      ).round();
      if (pct < 50 && actions.isNotEmpty) {
        return HomeRecommendationStrings.format(
          'advice_category_low',
          locale,
          params: {
            'category': label,
            'pct': '$pct',
            'action': actions.first.title,
          },
        );
      }
      final actionHint = actions.isNotEmpty
          ? actions.first.title
          : HomeRecommendationStrings.t('gap_category_action', locale).replaceAll(
              '{category}',
              label,
            );
      return HomeRecommendationStrings.format(
        'advice_category_grow',
        locale,
        params: {'category': label, 'action': actionHint},
      );
    }

    if (score.weeklyGrowth > 0.5) {
      return HomeRecommendationStrings.format(
        'advice_weekly_up',
        locale,
        params: {'delta': '${score.weeklyGrowth.round()}'},
      );
    }

    return HomeRecommendationStrings.t('advice_on_track', locale);
  }

  static List<ExpatScoreRecommendation> buildDetailRecommendations({
    required ExpatLifeScore score,
    required List<ScoreAction> actions,
    String locale = 'English',
  }) {
    if (actions.isNotEmpty) {
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

    final meta = score.categoryMeta;
    final recommendations = <ExpatScoreRecommendation>[];

    for (final entry in _sortedCategoryGaps(score, meta)) {
      final categoryMeta = meta[entry.key];
      if (categoryMeta?.insufficientData == true) {
        recommendations.add(
          ExpatScoreRecommendation(
            action: _insufficientDataAction(entry.key, locale),
            points: 5,
            duration: HomeRecommendationStrings.t('time_5_min', locale),
            routeTarget: _routeTargetForCategoryGap(entry.key),
          ),
        );
      } else if (categoryMeta?.changeExplanation != null) {
        recommendations.add(
          ExpatScoreRecommendation(
            action: categoryMeta!.changeExplanation!.why,
            points: 8,
            duration: HomeRecommendationStrings.t('time_3_min', locale),
            routeTarget: ExpatScoreRouteTarget.tool,
          ),
        );
      }
      if (recommendations.length >= 3) break;
    }

    return recommendations;
  }

  static String? _categoryWithRiskExplanation(
    Map<String, ExpatScoreCategoryMeta> meta,
  ) {
    for (final key in ['financial', 'documentation']) {
      final category = meta[key];
      if (category?.changeExplanation != null &&
          category!.evidenceLines.any((line) => line.startsWith('Risk:'))) {
        return key;
      }
    }
    return null;
  }

  static String? _categoryWithLowConfidence(
    Map<String, ExpatScoreCategoryMeta> meta,
  ) {
    for (final entry in meta.entries) {
      if (entry.value.confidence < 0.85 &&
          entry.value.evidenceLines.any((line) => line.startsWith('Data mismatch:'))) {
        return entry.key;
      }
    }
    return null;
  }

  static MapEntry<String, double>? _lowestScoringCategory(
    ExpatLifeScore score,
    Map<String, ExpatScoreCategoryMeta> meta,
  ) {
    final breakdown = {
      'career': score.career,
      'housing': score.housing,
      'financial': score.financial,
      'community': score.community,
      'documentation': score.documentation,
    };

    MapEntry<String, double>? lowest;
    for (final entry in breakdown.entries) {
      if (meta[entry.key]?.insufficientData == true) {
        return entry;
      }
      if (lowest == null || entry.value < lowest.value) {
        lowest = entry;
      }
    }
    return lowest;
  }

  static List<MapEntry<String, double>> _sortedCategoryGaps(
    ExpatLifeScore score,
    Map<String, ExpatScoreCategoryMeta> meta,
  ) {
    final breakdown = {
      'career': score.career,
      'housing': score.housing,
      'financial': score.financial,
      'community': score.community,
      'documentation': score.documentation,
    };

    final entries = breakdown.entries.toList()
      ..sort((a, b) {
        final aInsufficient = meta[a.key]?.insufficientData == true;
        final bInsufficient = meta[b.key]?.insufficientData == true;
        if (aInsufficient != bInsufficient) {
          return aInsufficient ? -1 : 1;
        }
        return a.value.compareTo(b.value);
      });
    return entries;
  }

  static String _routeTargetForCategoryGap(String categoryKey) {
    return switch (categoryKey) {
      'community' => ExpatScoreRouteTarget.community,
      _ => ExpatScoreRouteTarget.tool,
    };
  }

  static String _insufficientDataAction(String categoryKey, String locale) {
    switch (categoryKey) {
      case 'housing':
        return HomeRecommendationStrings.t('gap_housing_action', locale);
      case 'community':
        return HomeRecommendationStrings.t('gap_community_action', locale);
      default:
        return HomeRecommendationStrings.format(
          'gap_category_action',
          locale,
          params: {'category': _categoryLabel(categoryKey, locale)},
        );
    }
  }
}
