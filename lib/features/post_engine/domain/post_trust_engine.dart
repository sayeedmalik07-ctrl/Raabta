import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:raabta/features/post_engine/config/post_engine_config.dart';
import 'package:raabta/features/post_engine/domain/post_duplicate_detector.dart';
import 'package:raabta/features/post_engine/domain/post_intelligence_adapter.dart';
import 'package:raabta/features/post_engine/domain/post_trust_risk_gate.dart';

/// Pre-publish trust evaluation — deterministic checks on every listing;
/// AI moderation only when [PostTrustRiskGate] escalates (Part 7C).
class PostTrustEngine {
  const PostTrustEngine({
    PostDuplicateDetector? duplicates,
    PostIntelligenceAdapter? intelligence,
  })  : _duplicates = duplicates ?? const PostDuplicateDetector(),
        _intelligence = intelligence;

  final PostDuplicateDetector _duplicates;
  final PostIntelligenceAdapter? _intelligence;

  Future<PostTrustEvaluation> evaluate({
    required Map<String, dynamic> fieldValues,
    required String verticalId,
    required String categoryPath,
    String? userId,
    String locale = 'English',
    List<Map<String, dynamic>> existingListings = const [],
    String? resumeListingId,
  }) async {
    final flags = <String>[];
    var score = 100;

    if (_duplicates.isDuplicate(
      fieldValues: fieldValues,
      categoryPath: categoryPath,
      existingListings: existingListings,
      resumeListingId: resumeListingId,
    )) {
      flags.add('duplicate_listing');
      score -= 40;
    }

    final priceFlag = _checkSuspiciousPrice(fieldValues);
    if (priceFlag != null) {
      flags.add(priceFlag);
      score -= 25;
    }

    if (_missingContact(fieldValues, verticalId)) {
      flags.add('missing_contact');
      score -= 15;
    }

    var aiModerationRan = false;
    if (_intelligence != null &&
        PostTrustRiskGate.shouldEscalateToAi(
          categoryPath: categoryPath,
          fieldValues: fieldValues,
          deterministicFlags: flags,
        )) {
      aiModerationRan = true;
      final aiFlags = await _intelligence.detectRisk(
        fieldValues: fieldValues,
        locale: locale,
        userId: userId,
      );
      if (aiFlags != null && aiFlags.isNotEmpty) {
        for (final flag in aiFlags) {
          flags.add('ai_${flag.replaceAll(' ', '_')}');
        }
        score -= 15;
      }
    }

    final outcome = _outcomeForScore(score, flags);
    return PostTrustEvaluation(
      outcome: outcome,
      score: score.clamp(0, 100),
      flags: flags,
      userMessage: _messageForOutcome(outcome),
      backendNote: PostTrustBoundary.proposalDoc,
      aiModerationRan: aiModerationRan,
    );
  }

  String? _checkSuspiciousPrice(Map<String, dynamic> values) {
    final raw = values['price'] ?? values['pricePerMonth'] ?? values['salary'];
    if (raw == null) return null;
    final n = num.tryParse(raw.toString().replaceAll(RegExp(r'[^\d.]'), ''));
    if (n == null) return null;
    if (n <= 0) return 'invalid_price';
    if (n == 1) return 'suspicious_price';
    return null;
  }

  bool _missingContact(Map<String, dynamic> values, String verticalId) {
    if (verticalId == 'jobs') {
      return (values['contact']?.toString().trim().isEmpty ?? true) &&
          (values['email']?.toString().trim().isEmpty ?? true);
    }
    if (verticalId == 'housing') {
      return (values['phone']?.toString().trim().isEmpty ?? true) &&
          (values['whatsapp']?.toString().trim().isEmpty ?? true);
    }
    return false;
  }

  PostTrustOutcome _outcomeForScore(int score, List<String> flags) {
    if (flags.contains('duplicate_listing') || score < 40) {
      return PostTrustOutcome.block;
    }
    if (score < 75 || flags.isNotEmpty) {
      return PostTrustOutcome.reviewRequired;
    }
    return PostTrustOutcome.pass;
  }

  String _messageForOutcome(PostTrustOutcome outcome) {
    return switch (outcome) {
      PostTrustOutcome.pass => '',
      PostTrustOutcome.reviewRequired =>
        'Additional verification required before publishing',
      PostTrustOutcome.block =>
        'Additional verification required before publishing',
    };
  }
}

enum PostTrustOutcome { pass, reviewRequired, block }

class PostTrustEvaluation {
  const PostTrustEvaluation({
    required this.outcome,
    required this.score,
    required this.flags,
    required this.userMessage,
    this.backendNote,
    this.aiModerationRan = false,
  });

  final PostTrustOutcome outcome;
  final int score;
  final List<String> flags;
  final String userMessage;
  final String? backendNote;
  final bool aiModerationRan;

  bool get allowed => outcome != PostTrustOutcome.block;

  /// Legacy compat for pre-Part-4 callers.
  PostTrustResult toLegacyResult() => PostTrustResult(
        allowed: allowed,
        score: score,
        flags: flags,
        outcome: outcome,
        message: userMessage,
        aiModerationRan: aiModerationRan,
      );
}

class PostTrustResult {
  const PostTrustResult({
    required this.allowed,
    required this.score,
    required this.flags,
    this.outcome = PostTrustOutcome.pass,
    this.message = '',
    this.aiModerationRan = false,
  });

  final bool allowed;
  final int score;
  final List<String> flags;
  final PostTrustOutcome outcome;
  final String message;
  final bool aiModerationRan;
}

/// Fingerprint for duplicate detection — deterministic, no AI.
///
/// Jobs J1: [salary] is intentionally excluded from the price segment — same
/// title/location with different salary remains a duplicate for the same user.
///
/// Vehicle make/brand: title fallback mirrors [PostSchemaAdapter._titleFromValues]
/// (`title → brand → model`), then `make` when model is absent (form uses `make`,
/// not `brand`).
String postListingFingerprint({
  required Map<String, dynamic> fieldValues,
  required String categoryPath,
}) {
  final rawTitle = fieldValues['title']?.toString().trim();
  final rawBrand = fieldValues['brand']?.toString().trim();
  final rawModel = fieldValues['model']?.toString().trim();
  final rawMake = fieldValues['make']?.toString().trim();
  final titleSource = (rawTitle != null && rawTitle.isNotEmpty)
      ? rawTitle
      : (rawBrand != null && rawBrand.isNotEmpty)
          ? rawBrand
          : (rawModel != null && rawModel.isNotEmpty)
              ? rawModel
              : (rawMake ?? '');
  final title = titleSource.toString().trim().toLowerCase();
  // Price segment: `price` / `pricePerMonth` only — not Jobs `salary` (J1).
  final price = (fieldValues['price'] ?? fieldValues['pricePerMonth'] ?? '')
      .toString()
      .trim();
  final location = (fieldValues['location'] ?? fieldValues['area'] ?? '')
      .toString()
      .trim()
      .toLowerCase();
  final payload = '$categoryPath|$title|$price|$location';
  return sha256.convert(utf8.encode(payload)).toString();
}
