import 'package:scam_shield_core/features/scam_shield/domain/evidence/outdated_brand_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class OutdatedBrandEvidenceGenerator {
  static const priority = 180;

  static List<ScamEvidence> generate(String text) {
    final hit = OutdatedBrandDetector.detect(text);
    if (hit == null) return const [];
    final entry = hit.entry;
    return [
      ScamEvidence(
        kind: ScamEvidenceKind.outdatedBrandReference,
        priority: priority,
        textKey: 'ss_evidence_outdated_brand',
        params: {
          'name': entry.name,
          'replacement': entry.replacement,
          'since': entry.since,
        },
        sourceLabel: entry.sourceLabel,
        sourceUrl: entry.sourceUrl.isEmpty ? null : entry.sourceUrl,
        direction: ScamEvidenceDirection.informational,
      ),
    ];
  }
}
