import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';

abstract final class ScamPatternPackParser {
  static ScamPatternPack parse(Map<String, dynamic> json) {
    final kindRaw = json['evidenceKind']?.toString() ?? '';
    final kind = ScamPatternEvidenceKind.values.firstWhere(
      (k) => k.name == kindRaw,
      orElse: () => ScamPatternEvidenceKind.recoveryOffer,
    );
    final groupsRaw = json['groups'] as List<dynamic>? ?? [];
    return ScamPatternPack(
      id: json['id']?.toString() ?? '',
      verified: json['verified'] == true,
      localFlag: json['localFlag']?.toString() ?? '',
      evidenceKind: kind,
      minGroups: json['minGroups'] as int? ?? 1,
      sourceLabel: json['sourceLabel']?.toString() ?? 'Pattern check',
      evidenceTextKey: json['evidenceTextKey']?.toString() ?? '',
      sourceUrl: json['sourceUrl'] as String?,
      groups: [
        for (final g in groupsRaw)
          if (g is Map<String, dynamic>)
            ScamPatternGroup(
              id: g['id']?.toString() ?? '',
              patterns: [
                for (final p in (g['patterns'] as List<dynamic>? ?? []))
                  p.toString(),
              ],
            ),
      ],
    );
  }
}
