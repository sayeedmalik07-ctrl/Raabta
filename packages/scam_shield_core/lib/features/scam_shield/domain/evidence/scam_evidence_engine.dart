import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/advisory_match_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/domain_directory_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/claimed_entity_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_attack_stage_engine.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/money_mule_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/pattern_pack_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/event_ticket_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/outdated_brand_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/payment_red_flag_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/personal_context_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/sender_channel_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/generators/sideload_evidence.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class ScamEvidenceEngine {
  static const maxItems = 6;
  static const uiTop = 3;

  static ScamEvidenceHeadline headline(EvidenceEngineInput input) {
    final claimed = ClaimedEntityEvidenceGenerator.headline(
      input.text,
      input.locale,
    );
    if (claimed.textKey != 'ss_evidence_headline_generic') return claimed;
    if (input.attackStage != null) {
      final keys = ScamAttackStageEngine.stageSummaryKeys(input.attackStage!);
      if (keys.isNotEmpty) {
        return ScamEvidenceHeadline(textKey: keys.first);
      }
    }
    return claimed;
  }

  static List<ScamEvidence> mergeAsyncItems({
    required List<ScamEvidence> base,
    required List<ScamEvidence> asyncItems,
  }) {
    if (asyncItems.isEmpty) return base;
    final merged = [...base, ...asyncItems];
    merged.sort((a, b) => b.priority.compareTo(a.priority));
    final seen = <ScamEvidenceKind>{};
    final deduped = <ScamEvidence>[];
    for (final item in merged) {
      if (seen.add(item.kind)) deduped.add(item);
      if (deduped.length >= maxItems) break;
    }
    return deduped;
  }

  static List<ScamEvidence> compute(EvidenceEngineInput input) {
    final merged = <ScamEvidence>[
      ...DomainDirectoryEvidenceGenerator.generate(
        text: input.text,
        locale: input.locale,
        findings: input.urlFindings,
      ),
      ...AdvisoryMatchEvidenceGenerator.generate(
        text: input.text,
        locale: input.locale,
        advisories: input.advisories,
      ),
      ...SenderChannelEvidenceGenerator.generate(
        text: input.text,
        locale: input.locale,
        senderType: input.senderType,
        localFlags: input.localFlags,
      ),
      ...MoneyMuleEvidenceGenerator.generate(input.text),
      ...PaymentRedFlagEvidenceGenerator.generate(input.localFlags),
      ...SideloadEvidenceGenerator.generate(input.localFlags),
      ...PatternPackEvidenceGenerator.generate(
        text: input.text,
        localFlags: input.localFlags,
        urlFindings: input.urlFindings,
      ),
      ...PersonalContextEvidenceGenerator.generate(
        text: input.text,
        locale: input.locale,
        personalContext: input.personalContext,
      ),
      ...EventTicketEvidenceGenerator.generate(input.text),
      ...OutdatedBrandEvidenceGenerator.generate(input.text),
    ];

    merged.sort((a, b) => b.priority.compareTo(a.priority));

    final seen = <ScamEvidenceKind>{};
    final deduped = <ScamEvidence>[];
    for (final item in merged) {
      if (seen.add(item.kind)) deduped.add(item);
      if (deduped.length >= maxItems) break;
    }
    return deduped;
  }
}
