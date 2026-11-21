import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';

class CostOfLivingCategory {
  const CostOfLivingCategory({
    required this.code,
    required this.name,
    required this.cpiIndex,
    this.priorIndex,
    required this.trend,
    this.changePctMom,
    this.featured = false,
  });

  final String code;
  final String name;
  final double cpiIndex;
  final double? priorIndex;
  final CostOfLivingTrend trend;
  final double? changePctMom;
  final bool featured;

  String get displayName =>
      CostOfLivingConstants.featuredCategoryLabels[code] ?? name;

  factory CostOfLivingCategory.fromJson(Map<String, dynamic> json) {
    return CostOfLivingCategory(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cpiIndex: (json['cpi_index'] as num?)?.toDouble() ?? 0,
      priorIndex: (json['prior_index'] as num?)?.toDouble(),
      trend: trendFromString(json['trend']?.toString()),
      changePctMom: (json['change_pct_mom'] as num?)?.toDouble(),
      featured: json['featured'] == true,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'code': code,
        'name': name,
        'cpi_index': cpiIndex,
        'prior_index': priorIndex,
        'trend': switch (trend) {
          CostOfLivingTrend.up => 'up',
          CostOfLivingTrend.down => 'down',
          CostOfLivingTrend.flat => 'flat',
        },
        'change_pct_mom': changePctMom,
        'featured': featured,
      };
}

class QualityOfLifeSnapshot {
  const QualityOfLifeSnapshot({
    required this.score,
    required this.rank,
    required this.year,
    required this.timePeriod,
    required this.sourceLabel,
  });

  final double score;
  final int rank;
  final String year;
  final String timePeriod;
  final String sourceLabel;

  factory QualityOfLifeSnapshot.fromJson(Map<String, dynamic> json) {
    return QualityOfLifeSnapshot(
      score: (json['score'] as num?)?.toDouble() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      year: json['year']?.toString() ?? '',
      timePeriod: json['time_period']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'score': score,
        'rank': rank,
        'year': year,
        'time_period': timePeriod,
        'source_label': sourceLabel,
      };
}

class CostOfLivingSnapshot {
  const CostOfLivingSnapshot({
    required this.id,
    required this.cpiSourceDateLabel,
    this.qolSourceDateLabel,
    this.qualityOfLife,
    required this.categories,
    this.generalCpi,
    this.aiSummary,
    required this.fetchedAt,
    this.isFromCache = false,
    this.isDirectApi = false,
    this.disclaimer = CostOfLivingConstants.disclaimer,
  });

  final String id;
  final String cpiSourceDateLabel;
  final String? qolSourceDateLabel;
  final QualityOfLifeSnapshot? qualityOfLife;
  final List<CostOfLivingCategory> categories;
  final double? generalCpi;
  final String? aiSummary;
  final DateTime fetchedAt;
  final bool isFromCache;
  final bool isDirectApi;
  final String disclaimer;

  List<CostOfLivingCategory> get featuredCategories =>
      categories.where((c) => c.featured).toList();

  CostOfLivingCategory? categoryByCode(String code) {
    for (final c in categories) {
      if (c.code == code) return c;
    }
    return null;
  }

  factory CostOfLivingSnapshot.fromJson(
    Map<String, dynamic> json, {
    bool isFromCache = false,
  }) {
    final qolRaw = json['quality_of_life'];
    return CostOfLivingSnapshot(
      id: json['id']?.toString() ?? '',
      cpiSourceDateLabel:
          json['cpi_source_date_label']?.toString() ?? 'Unknown period',
      qolSourceDateLabel: json['qol_source_date_label']?.toString(),
      qualityOfLife: qolRaw is Map<String, dynamic>
          ? QualityOfLifeSnapshot.fromJson(qolRaw)
          : null,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CostOfLivingCategory.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
      generalCpi: (json['general_cpi'] as num?)?.toDouble(),
      aiSummary: json['ai_summary']?.toString(),
      fetchedAt: DateTime.tryParse(json['fetched_at']?.toString() ?? '') ??
          DateTime.tryParse(json['last_updated']?.toString() ?? '') ??
          DateTime.now(),
      isFromCache: isFromCache,
      isDirectApi:
          json['is_direct_api'] == true ||
          json['id']?.toString() == 'direct_api',
      disclaimer:
          json['disclaimer']?.toString() ?? CostOfLivingConstants.disclaimer,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'cpi_source_date_label': cpiSourceDateLabel,
        'qol_source_date_label': qolSourceDateLabel,
        'quality_of_life': qualityOfLife?.toCacheJson(),
        'categories': categories.map((c) => c.toCacheJson()).toList(),
        'general_cpi': generalCpi,
        'ai_summary': aiSummary,
        'fetched_at': fetchedAt.toIso8601String(),
        'disclaimer': disclaimer,
        'is_direct_api': isDirectApi,
      };

  CostOfLivingSnapshot copyWith({bool? isFromCache, bool? isDirectApi}) {
    return CostOfLivingSnapshot(
      id: id,
      cpiSourceDateLabel: cpiSourceDateLabel,
      qolSourceDateLabel: qolSourceDateLabel,
      qualityOfLife: qualityOfLife,
      categories: categories,
      generalCpi: generalCpi,
      aiSummary: aiSummary,
      fetchedAt: fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
      isDirectApi: isDirectApi ?? this.isDirectApi,
      disclaimer: disclaimer,
    );
  }
}

/// Directional comparison between Bill Tracker totals and CPI trend.
class PersonalCostComparison {
  const PersonalCostComparison({
    required this.categoryLabel,
    required this.userTrendLabel,
    required this.cpiTrendLabel,
    required this.cpiSourceDateLabel,
    required this.aligned,
    required this.body,
  });

  final String categoryLabel;
  final String userTrendLabel;
  final String cpiTrendLabel;
  final String cpiSourceDateLabel;
  final bool aligned;
  final String body;
}
