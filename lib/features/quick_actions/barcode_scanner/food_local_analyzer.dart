import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';

import 'l10n/food_inspector_strings.dart';
import 'models/dietary_profile.dart';
import 'models/halal_product_info.dart';
import 'services/ingredient_awareness_parser.dart';
import 'services/open_food_facts_halal_parser.dart';

/// Deterministic product analysis from Open Food Facts — used when AI is unavailable.
class LocalFoodAnalysis {
  const LocalFoodAnalysis({
    required this.healthScore,
    required this.verdict,
    required this.verdictColor,
    required this.motivationalMessage,
    required this.summary,
    required this.nutrients,
    required this.additives,
    required this.allergyWarnings,
    required this.halalInfo,
    required this.usedOfflineEngine,
  });

  final int healthScore;
  final String verdict;
  final Color verdictColor;
  final String motivationalMessage;
  final String summary;
  final List<LocalNutrientInfo> nutrients;
  final List<LocalAdditiveInfo> additives;
  final List<String> allergyWarnings;
  final HalalProductInfo halalInfo;
  final bool usedOfflineEngine;
}

class LocalNutrientInfo {
  const LocalNutrientInfo({
    required this.name,
    required this.amount,
    required this.per100g,
    required this.dailyPct,
  });

  final String name;
  final String amount;
  final double per100g;
  final double dailyPct;
}

class LocalAdditiveInfo {
  const LocalAdditiveInfo({
    required this.code,
    required this.plainName,
    required this.status,
    required this.reason,
  });

  final String code;
  final String plainName;
  final String status;
  final String reason;
}

abstract final class FoodLocalAnalyzer {
  static LocalFoodAnalysis analyze({
    required Map<String, dynamic> product,
    required String language,
    DietaryProfile? profile,
    List<LocalAdditiveInfo>? resolvedAdditives,
    bool useReferenceSummary = false,
  }) {
    final locale = AppLocale.normalize(language);
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final ingredients = (
      product['ingredients_text'] ??
      product['ingredients_text_en'] ??
      ''
    ).toString().toLowerCase();

    var score = _scoreFromNutriGrade(product['nutriscore_grade'] as String?);
    score += _novaAdjustment(product['nova_group']);

    final sugar = _num(nutriments['sugars_100g']);
    final salt = _num(nutriments['salt_100g'] ?? nutriments['sodium_100g']);
    final satFat = _num(nutriments['saturated-fat_100g']);
    if (sugar > 15) score -= 8;
    if (salt > 1.5) score -= 6;
    if (satFat > 5) score -= 6;
    score = score.clamp(0, 100);

    final verdictLabel = FoodInspectorStrings.verdictLabel(score, locale);
    final color = _colorForScore(score);
    final nutrients = _buildNutrients(nutriments, locale);
    final additives = resolvedAdditives ??
        _buildAdditives(product, ingredients);
    final ingredientsRaw = (
      product['ingredients_text'] ??
      product['ingredients_text_en'] ??
      ''
    ).toString();
    final awareness = IngredientAwarenessParser.parse(ingredientsRaw);
    final halalInfo = OpenFoodFactsHalalParser.parse(
      product: product,
      awarenessItems: awareness,
    );
    final allergies = _matchAllergies(ingredients, profile, locale);

    if (allergies.isNotEmpty) score = (score - 10).clamp(0, 100);
    final avoidCount =
        additives.where((a) => a.status.toLowerCase() == 'avoid').length;
    if (avoidCount > 0) {
      score = (score - (avoidCount * 5)).clamp(0, 100);
    }

    final productName = product['product_name'] ??
        product['product_name_en'] ??
        FoodInspectorStrings.t('unknown_product', locale);

    return LocalFoodAnalysis(
      healthScore: score,
      verdict: verdictLabel,
      verdictColor: color,
      motivationalMessage: FoodInspectorStrings.verdictMessage(score, locale),
      summary: FoodInspectorStrings.buildSummary(
        productName: productName.toString(),
        score: score,
        verdict: verdictLabel,
        locale: locale,
        useReferenceSummary: useReferenceSummary,
      ),
      nutrients: nutrients,
      additives: additives,
      allergyWarnings: allergies,
      halalInfo: halalInfo,
      usedOfflineEngine: true,
    );
  }

  static int _scoreFromNutriGrade(String? grade) {
    return switch (grade?.toLowerCase()) {
      'a' => 88,
      'b' => 74,
      'c' => 58,
      'd' => 42,
      'e' => 28,
      _ => 52,
    };
  }

  static int _novaAdjustment(dynamic nova) {
    final group = nova is num ? nova.toInt() : int.tryParse('$nova') ?? 0;
    return switch (group) {
      1 => 8,
      2 => 4,
      3 => 0,
      4 => -12,
      _ => 0,
    };
  }

  static double _num(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static Color _colorForScore(int score) {
    if (score >= 85) return AppColors.successBright;
    if (score >= 70) return const Color(0xFF7BC67E);
    if (score >= 50) return AppColors.accentGold;
    if (score >= 30) return AppColors.heatOrange;
    return AppColors.errorBright;
  }

  static List<LocalNutrientInfo> _buildNutrients(
    Map<String, dynamic> n,
    String locale,
  ) {
    final rows = <LocalNutrientInfo>[];

    void add(String key, String labelKey, double dailyRef) {
      final value = _num(n[key]);
      if (value <= 0) return;
      rows.add(
        LocalNutrientInfo(
          name: FoodInspectorStrings.nutrientLabel(labelKey, locale),
          amount: '${value.toStringAsFixed(1)}g',
          per100g: value,
          dailyPct: dailyRef > 0 ? (value / dailyRef * 100).clamp(0, 150) : 0,
        ),
      );
    }

    add('energy-kcal_100g', 'nutrient_energy', 2000);
    add('fat_100g', 'nutrient_fat', 70);
    add('saturated-fat_100g', 'nutrient_saturated_fat', 20);
    add('sugars_100g', 'nutrient_sugar', 90);
    add('salt_100g', 'nutrient_salt', 6);
    add('proteins_100g', 'nutrient_protein', 50);
    add('carbohydrates_100g', 'nutrient_carbs', 260);
    add('fiber_100g', 'nutrient_fiber', 25);

    return rows.take(8).toList();
  }

  static List<LocalAdditiveInfo> _buildAdditives(
    Map<String, dynamic> product,
    String ingredients,
  ) {
    final tags = product['additives_tags'] as List<dynamic>? ?? [];
    final fromTags = tags.map((tag) {
      final raw = tag.toString();
      final code = raw.contains(':')
          ? raw.split(':').last.toUpperCase()
          : raw.toUpperCase();
      return LocalAdditiveInfo(
        code: code.startsWith('E') ? code : 'E$code',
        plainName: 'Food additive',
        status: 'caution',
        reason: 'Check label if you avoid processed additives.',
      );
    });

    if (fromTags.isNotEmpty) return fromTags.take(8).toList();

    final found = <LocalAdditiveInfo>[];
    for (final entry in _knownAdditives.entries) {
      if (ingredients.contains(entry.key)) {
        found.add(entry.value);
      }
    }
    return found.take(8).toList();
  }

  static List<String> _matchAllergies(
    String ingredients,
    DietaryProfile? profile,
    String locale,
  ) {
    if (profile == null || profile.allergies.isEmpty) return const [];
    final warnings = <String>[];
    for (final allergy in profile.allergies) {
      final key = allergy.toLowerCase();
      if (_ingredientMatchesAllergy(ingredients, key)) {
        warnings.add(
          FoodInspectorStrings.format(
            'allergy_detected',
            locale,
            {
              'allergen': FoodInspectorStrings.allergenLabel(allergy, locale),
            },
          ),
        );
      }
    }
    return warnings;
  }

  static bool _ingredientMatchesAllergy(String ingredients, String allergy) {
    final tokens = allergy
        .replaceAll('/', ' ')
        .split(' ')
        .where((t) => t.length > 2)
        .map((t) => t.toLowerCase());
    for (final token in tokens) {
      if (ingredients.contains(token)) return true;
    }
    return switch (allergy) {
      'milk / dairy' || 'milk' || 'dairy' =>
        ingredients.contains('milk') || ingredients.contains('lactose'),
      'wheat / gluten' || 'wheat' || 'gluten' =>
        ingredients.contains('wheat') || ingredients.contains('gluten'),
      'tree nuts' || 'nuts' =>
        ingredients.contains('nut') || ingredients.contains('almond'),
      _ => false,
    };
  }

  static const _knownAdditives = {
    'monosodium glutamate': LocalAdditiveInfo(
      code: 'MSG',
      plainName: 'Flavor enhancer',
      status: 'caution',
      reason: 'Some people prefer to limit MSG intake.',
    ),
    'aspartame': LocalAdditiveInfo(
      code: 'E951',
      plainName: 'Artificial sweetener',
      status: 'caution',
      reason: 'Check if you avoid artificial sweeteners.',
    ),
    'sodium benzoate': LocalAdditiveInfo(
      code: 'E211',
      plainName: 'Preservative',
      status: 'caution',
      reason: 'Common preservative in processed foods.',
    ),
  };
}
