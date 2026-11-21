import 'dart:convert';

import 'package:raabta/features/post_engine/config/post_engine_config.dart';
import 'package:raabta/features/post_engine/data/post_intelligence_usage_repository.dart';
import 'package:raabta/features/post_engine/domain/post_duplicate_detector.dart';
import 'package:raabta/features/post_engine/domain/post_price_suggester.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Routes Post Engine AI through [ClaudeAIService] — no parallel AI system.
class PostIntelligenceAdapter {
  PostIntelligenceAdapter({
    ClaudeAIService? ai,
    PostIntelligenceUsageRepository? usage,
    PostPriceSuggester? priceSuggester,
    PostDuplicateDetector? duplicateDetector,
  })  : _ai = ai ?? ClaudeAIService(),
        _usage = usage ?? PostIntelligenceUsageRepository(),
        _priceSuggester = priceSuggester ?? const PostPriceSuggester(),
        _duplicates = duplicateDetector ?? const PostDuplicateDetector();

  final ClaudeAIService _ai;
  final PostIntelligenceUsageRepository _usage;
  final PostPriceSuggester _priceSuggester;
  final PostDuplicateDetector _duplicates;

  Future<PostCategorySuggestion?> detectCategory({
    required String freeText,
    required String locale,
    String? userId,
  }) async {
    return _aiJson<PostCategorySuggestion>(
      requestType: PostEngineConfig.detectCategoryRequestType,
      prompt:
          'Classify this listing for Raabta marketplace. Return JSON only: '
          '{"vertical":"marketplace|housing|jobs|business|services",'
          '"categoryPath":"dot.separated.path","confidence":0.0-1.0}\n\n'
          'Listing: $freeText',
      locale: locale,
      userId: userId,
      parse: (json) => PostCategorySuggestion(
        verticalId: json['vertical']?.toString() ?? 'marketplace',
        categoryPath: json['categoryPath']?.toString() ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  /// One AI call per submitted description — extracts category + request fields.
  Future<PostServiceRequestExtraction?> extractServiceRequest({
    required String freeText,
    required String categoryCatalog,
    required String locale,
    String? userId,
  }) async {
    return _aiJson<PostServiceRequestExtraction>(
      requestType: PostEngineConfig.extractServiceRequestRequestType,
      prompt:
          'Extract a Raabta Qatar service customer request from the description. '
          'Return JSON only:\n'
          '{"categoryPath":"dot.separated.path","confidence":0.0-1.0,'
          '"fields":{"need_description":"...","urgency":"urgency_today|'
          'urgency_this_week|urgency_flexible",'
          '"problem":"svc_prob_* if applicable","preferred_time":"...",'
          '"budget_range":"...","notes":"..."}}\n'
          'Use only categoryPath values from this list:\n$categoryCatalog\n'
          'Use only urgency keys: urgency_today, urgency_this_week, '
          'urgency_flexible.\n'
          'Only include fields you can infer confidently. '
          'Do not invent contact details.\n\n'
          'Customer description:\n$freeText',
      locale: locale,
      userId: userId,
      parse: (json) {
        final map = json is Map<String, dynamic>
            ? json
            : Map<String, dynamic>.from(json as Map);
        final fieldsRaw = map['fields'];
        final fields = fieldsRaw is Map
            ? Map<String, dynamic>.from(fieldsRaw)
            : <String, dynamic>{};
        if (fields['need_description'] == null ||
            fields['need_description'].toString().trim().isEmpty) {
          fields['need_description'] = freeText.trim();
        }
        return PostServiceRequestExtraction(
          categoryPath: map['categoryPath']?.toString() ?? '',
          confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
          fieldValues: fields,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> extractAttributes({
    required String freeText,
    required String categoryPath,
    required String locale,
    String? userId,
  }) async {
    return _aiJson<Map<String, dynamic>>(
      requestType: PostEngineConfig.extractAttributesRequestType,
      prompt:
          'Extract structured listing fields as JSON keys/values for category '
          '$categoryPath. Use snake_case keys matching common fields '
          '(brand, model, condition, price, storage, etc). Text:\n$freeText',
      locale: locale,
      userId: userId,
      parse: (json) => Map<String, dynamic>.from(json),
    );
  }

  Future<String?> generateTitle({
    required Map<String, dynamic> fieldValues,
    required String locale,
    String? userId,
  }) async {
    return _aiText(
      requestType: PostEngineConfig.generateTitleRequestType,
      prompt:
          'Write a concise marketplace listing title (max 80 chars) from: '
          '${jsonEncode(fieldValues)}',
      locale: locale,
      userId: userId,
    );
  }

  Future<String?> generateDescription({
    required Map<String, dynamic> fieldValues,
    required String locale,
    String? userId,
  }) async {
    return _aiText(
      requestType: PostEngineConfig.generateDescriptionRequestType,
      prompt:
          'Write a friendly listing description (80-200 words) from: '
          '${jsonEncode(fieldValues)}',
      locale: locale,
      userId: userId,
    );
  }

  Future<String?> improveListing({
    required Map<String, dynamic> fieldValues,
    required String locale,
    String? userId,
  }) async {
    return _aiText(
      requestType: PostEngineConfig.improveListingRequestType,
      prompt:
          'Suggest improvements for this listing draft as bullet points. '
          'Do not invent facts.\n${jsonEncode(fieldValues)}',
      locale: locale,
      userId: userId,
    );
  }

  /// Deterministic median — no AI unless [recentPrices] empty (returns null).
  PostPriceSuggestion? suggestPrice({
    required String categoryPath,
    required List<int> recentPrices,
  }) {
    return _priceSuggester.suggestPrice(
      categoryPath: categoryPath,
      recentPrices: recentPrices,
    );
  }

  List<PostDuplicateMatch> detectDuplicates({
    required Map<String, dynamic> fieldValues,
    required String categoryPath,
    required List<({String id, Map<String, dynamic> values})> candidates,
  }) {
    return _duplicates.detectDuplicates(
      fieldValues: fieldValues,
      categoryPath: categoryPath,
      candidates: candidates,
    );
  }

  Future<List<String>?> detectRisk({
    required Map<String, dynamic> fieldValues,
    required String locale,
    String? userId,
  }) async {
    return _aiJson<List<String>>(
      requestType: PostEngineConfig.detectRiskRequestType,
      prompt:
          'List risk flags (JSON array of strings) for this listing draft. '
          'Neutral tone, no accusations.\n${jsonEncode(fieldValues)}',
      locale: locale,
      userId: userId,
      parse: (json) {
        if (json is List) {
          return json.map((e) => e.toString()).toList();
        }
        final flags = json['flags'];
        if (flags is List) return flags.map((e) => e.toString()).toList();
        return const [];
      },
    );
  }

  Future<String?> suggestFieldValue({
    required String fieldId,
    required Map<String, dynamic> currentValues,
    required String locale,
    String? userId,
  }) async {
    return extractAttributes(
      freeText: jsonEncode(currentValues),
      categoryPath: currentValues['_categoryPath']?.toString() ?? '',
      locale: locale,
      userId: userId,
    ).then((m) => m?[fieldId]?.toString());
  }

  Future<String?> improveDescription({
    required String draft,
    required String locale,
    String? userId,
  }) async {
    return _aiText(
      requestType: PostEngineConfig.improveListingRequestType,
      prompt: 'Improve this listing description. Keep facts unchanged:\n$draft',
      locale: locale,
      userId: userId,
    );
  }

  Future<T?> _aiJson<T>({
    required String requestType,
    required String prompt,
    required String locale,
    required T Function(dynamic json) parse,
    String? userId,
  }) async {
    final text = await _aiText(
      requestType: requestType,
      prompt: prompt,
      locale: locale,
      userId: userId,
    );
    if (text == null || text.isEmpty) return null;
    try {
      final cleaned = text.replaceAll(RegExp(r'^```json|```\$', multiLine: true), '').trim();
      final decoded = jsonDecode(cleaned);
      return parse(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _aiText({
    required String requestType,
    required String prompt,
    required String locale,
    String? userId,
  }) async {
    if (!await _usage.canUse(requestType)) return null;
    final reply = await _ai.sendMessage(
      prompt,
      language: locale,
      requestType: requestType,
      languageCode: locale,
      userId: userId,
    );
    if (reply.trim().isEmpty) return null;
    await _usage.record(requestType);
    return reply.trim();
  }
}

class PostCategorySuggestion {
  const PostCategorySuggestion({
    required this.verticalId,
    required this.categoryPath,
    required this.confidence,
  });

  final String verticalId;
  final String categoryPath;
  final double confidence;
}

/// User must confirm before applying AI suggestions.
class PostIntelligenceSuggestion {
  const PostIntelligenceSuggestion({
    required this.fieldValues,
    required this.source,
    this.category,
    this.improvementNotes,
  });

  final Map<String, dynamic> fieldValues;
  final String source;
  final PostCategorySuggestion? category;
  final String? improvementNotes;
}

/// AI extraction for customer service requests — user must confirm before save.
class PostServiceRequestExtraction {
  const PostServiceRequestExtraction({
    required this.categoryPath,
    required this.confidence,
    required this.fieldValues,
  });

  final String categoryPath;
  final double confidence;
  final Map<String, dynamic> fieldValues;

  bool get isUsable => categoryPath.trim().isNotEmpty && confidence >= 0.35;
}
