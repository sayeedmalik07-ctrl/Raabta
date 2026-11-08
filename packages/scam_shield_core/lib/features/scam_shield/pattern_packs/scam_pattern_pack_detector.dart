import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_loader.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';

class ScamPatternPackMatch {
  const ScamPatternPackMatch({required this.pack, required this.matchedGroupIds});

  final ScamPatternPack pack;
  final List<String> matchedGroupIds;
}

abstract final class ScamPatternPackDetector {
  static Future<List<String>> detectLocalFlags(String text) async {
    final matches = await detectMatches(text);
    return matches.map((m) => m.pack.localFlag).toSet().toList();
  }

  static List<ScamPatternPackMatch> detectMatchesSync(String text) {
    final packs = ScamPatternPackLoader.cache;
    return _matchPacks(text, packs);
  }

  static Future<List<ScamPatternPackMatch>> detectMatches(String text) async {
    final packs = await ScamPatternPackLoader.loadAll();
    return _matchPacks(text, packs);
  }

  static List<ScamPatternPackMatch> _matchPacks(
    String text,
    List<ScamPatternPack> packs,
  ) {
    final lower = text.toLowerCase();
    final out = <ScamPatternPackMatch>[];
    for (final pack in packs) {
      if (!pack.verified) continue;
      final matched = <String>[];
      for (final group in pack.groups) {
        if (group.patterns.any(
          (p) => ScamMultilingualMatcher.containsPattern(lower, p),
        )) {
          matched.add(group.id);
        }
      }
      if (matched.length >= pack.minGroups) {
        out.add(ScamPatternPackMatch(pack: pack, matchedGroupIds: matched));
      }
    }
    return out;
  }

  static List<String> detectLocalFlagsSync(String text) {
    return detectMatchesSync(text).map((m) => m.pack.localFlag).toSet().toList();
  }

  /// Fake fine/toll: fine language + link whose domain is not in official directory.
  static bool detectFakeFineToll({
    required String text,
    required List<ScamShieldUrlFinding> urlFindings,
  }) {
    const fineTerms = [
      'unpaid traffic fine',
      'pay your fine',
      'toll fee',
      'customs fee',
      'غرامة',
      'fine payment',
    ];
    final lower = text.toLowerCase();
    final hasFine = fineTerms.any(
      (t) => ScamMultilingualMatcher.containsPattern(lower, t),
    );
    if (!hasFine) return false;
    if (urlFindings.isEmpty) return false;
    return urlFindings.any((f) {
      if (f.isKnownLegitimate) return false;
      return !OfficialDirectory.isKnownLegitimateHost(f.domain);
    });
  }
}
