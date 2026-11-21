import 'package:raabta/features/scam_shield/domain/evidence/scam_bridge_topic.dart';
import 'package:raabta/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_topic_classifier.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_models.dart';

/// Resolves at most one verified scam type for a scan or library browse.
abstract final class ScamTypeResolver {
  static String? resolveTypeId({
    required List<ScamTypeDefinition> verifiedTypes,
    required String text,
    required ScamShieldContentType contentType,
    required List<String> localFlags,
    required ScamScanRiskAnalysis scanAnalysis,
  }) {
    if (verifiedTypes.isEmpty) return null;

    final topic = ScamTopicClassifier.classify(
      text: text,
      contentType: contentType,
      localFlags: localFlags,
      scanAnalysis: scanAnalysis,
    );
    final topPattern = scanAnalysis.communityCorrelation.strongest?.patternId;
    final lower = text.toLowerCase();

    String? bestId;
    var bestScore = 0;

    for (final type in verifiedTypes) {
      final score = _scoreMatch(
        rules: type.match,
        topic: topic,
        topPattern: topPattern,
        contentType: contentType,
        localFlags: localFlags,
        lowerText: lower,
      );
      if (score > bestScore) {
        bestScore = score;
        bestId = type.id;
      }
    }

    return bestScore > 0 ? bestId : null;
  }

  static int _scoreMatch({
    required ScamTypeMatchRules rules,
    required ScamBridgeTopic topic,
    required String? topPattern,
    required ScamShieldContentType contentType,
    required List<String> localFlags,
    required String lowerText,
  }) {
    var score = 0;
    if (topPattern != null && rules.patternIds.contains(topPattern)) {
      score += 100;
    }
    if (rules.topics.contains(topic.name)) {
      score += 80;
    }
    if (rules.contentTypes.contains(contentType.name)) {
      score += 60;
    }
    for (final flag in rules.localFlags) {
      if (localFlags.contains(flag)) score += 40;
    }
    if (rules.terms.isNotEmpty) {
      var hits = 0;
      for (final term in rules.terms) {
        if (ScamMultilingualMatcher.containsPattern(lowerText, term)) {
          hits++;
        }
      }
      if (hits >= rules.minTermMatches) {
        score += 50 + hits;
      }
    }
    return score;
  }
}
