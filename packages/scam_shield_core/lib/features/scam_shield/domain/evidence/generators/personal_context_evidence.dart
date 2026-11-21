import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_models.dart';

abstract final class PersonalContextEvidenceGenerator {
  static const priority = 220;

  static List<ScamEvidence> generate({
    required String text,
    required String locale,
    required PersonalContextSnapshot personalContext,
  }) {
    if (personalContext.isEmpty) return const [];

    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    final claimedId = claim.primaryId;
    if (claimedId == null) return const [];

    final entry = OfficialDirectory.lookupById(claimedId);
    if (entry == null) return const [];

    if (entry.category != OfficialDirectoryCategory.banking &&
        entry.category != OfficialDirectoryCategory.telecom) {
      return const [];
    }

    final categoryKey = entry.category.name;
    if (!personalContext.hasSavedForCategory(categoryKey)) {
      return const [];
    }

    final saved = personalContext.savedIdsForCategory(categoryKey);
    if (saved.contains(claimedId)) return const [];

    return [
      ScamEvidence(
        kind: ScamEvidenceKind.personalContextMismatch,
        priority: priority,
        textKey: 'ss_evidence_personal_context_mismatch',
        params: {'entity': entry.displayName(locale)},
        sourceLabel: 'Pattern check',
        entityId: entry.id,
        direction: ScamEvidenceDirection.informational,
      ),
    ];
  }
}
