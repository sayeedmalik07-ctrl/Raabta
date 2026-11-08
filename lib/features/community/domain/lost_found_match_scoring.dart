import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/domain/lost_found_match_eligibility.dart';
import 'package:raabta/features/community/domain/lost_found_match_policy.dart';

/// Result of deterministic scoring (safe for tests; no private fields).
class LostFoundMatchScoreResult {
  const LostFoundMatchScoreResult({
    required this.score,
    required this.explanation,
    required this.eligible,
  });

  final int score;
  final List<String> explanation;
  final bool eligible;

  bool get meetsThreshold => score >= LostFoundMatchPolicy.matchScoreThreshold;
}

abstract final class LostFoundMatchScoring {
  static const colorOverlapPoints = 15;
  static const brandMatchPoints = 25;
  static const itemTypeOverlapPoints = 20;
  static const marksOverlapPoints = 15;
  static const groupOverlapPoints = 10;
  static const maxGroupPoints = 20;

  static LostFoundMatchScoreResult scorePair({
    required LostFoundMatchListing source,
    required LostFoundMatchListing candidate,
  }) {
    final fail = LostFoundMatchEligibility.mandatoryFailureReason(
      source,
      candidate,
    );
    if (fail != null) {
      return LostFoundMatchScoreResult(
        score: 0,
        explanation: ['ineligible:$fail'],
        eligible: false,
      );
    }

    final category = LostFoundCategory.normalize(source.category)!;
    if (category == LostFoundCategory.documentsCards) {
      return LostFoundMatchScoreResult(
        score: LostFoundMatchPolicy.matchScoreThreshold,
        explanation: const ['documents_cards:category_area_date_only'],
        eligible: true,
      );
    }

    var total = 0;
    final parts = <String>[];

    final srcAttrs = source.attributes;
    final candAttrs = candidate.attributes;

    final colorPts = _colorOverlap(
      srcAttrs?.colors ?? const [],
      candAttrs?.colors ?? const [],
    );
    if (colorPts > 0) {
      total += colorPts;
      parts.add('colors:+$colorPts');
    }

    final brandPts = _brandMatch(srcAttrs?.brand, candAttrs?.brand);
    if (brandPts > 0) {
      total += brandPts;
      parts.add('brand:+$brandPts');
    }

    final typePts = _tokenOverlapScore(
      _joinFields([
        srcAttrs?.itemType,
        source.title,
        source.itemDescription,
      ]),
      _joinFields([
        candAttrs?.itemType,
        candidate.title,
        candidate.itemDescription,
      ]),
      itemTypeOverlapPoints,
    );
    if (typePts > 0) {
      total += typePts;
      parts.add('item_type:+$typePts');
    }

    final marksPts = _tokenOverlapScore(
      srcAttrs?.marks ?? '',
      candAttrs?.marks ?? '',
      marksOverlapPoints,
    );
    if (marksPts > 0) {
      total += marksPts;
      parts.add('marks:+$marksPts');
    }

    final groupPts = _groupOverlap(
      source.relevantGroupIds,
      candidate.relevantGroupIds,
    );
    if (groupPts > 0) {
      total += groupPts;
      parts.add('groups:+$groupPts');
    }

    if (parts.isEmpty) {
      parts.add('no_optional_signals');
    }

    return LostFoundMatchScoreResult(
      score: total,
      explanation: parts,
      eligible: true,
    );
  }

  static int _colorOverlap(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final setB = b.toSet();
    var count = 0;
    for (final c in a) {
      if (setB.contains(c)) count++;
    }
    return count * colorOverlapPoints;
  }

  static int _brandMatch(String? a, String? b) {
    final na = _normalizeToken(a);
    final nb = _normalizeToken(b);
    if (na == null || nb == null) return 0;
    return na == nb ? brandMatchPoints : 0;
  }

  static int _groupOverlap(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final setB = b.toSet();
    var overlap = 0;
    for (final g in a) {
      if (setB.contains(g)) overlap++;
    }
    return (overlap * groupOverlapPoints).clamp(0, maxGroupPoints);
  }

  static int _tokenOverlapScore(String a, String b, int maxPoints) {
    final ta = _tokens(a);
    final tb = _tokens(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final inter = ta.intersection(tb);
    if (inter.isEmpty) return 0;
    final ratio = inter.length / ta.length.clamp(1, ta.length);
    final scaled = (ratio * maxPoints).round();
    return scaled.clamp(0, maxPoints);
  }

  static String _joinFields(List<String?> fields) {
    return fields.whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
  }

  static String? _normalizeToken(String? raw) {
    if (raw == null) return null;
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return null;
    return t.replaceAll(RegExp(r'\s+'), ' ');
  }

  static Set<String> _tokens(String raw) {
    final normalized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return {};
    return normalized
        .split(' ')
        .where((t) => t.length >= 3)
        .toSet();
  }
}
