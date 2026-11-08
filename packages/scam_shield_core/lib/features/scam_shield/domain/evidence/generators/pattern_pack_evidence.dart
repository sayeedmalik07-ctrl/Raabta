import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_detector.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_loader.dart';
import 'package:scam_shield_core/features/scam_shield/pattern_packs/scam_pattern_pack_models.dart';

abstract final class PatternPackEvidenceGenerator {
  static const recoveryPriority = 880;
  static const patternPriority = 650;

  static List<ScamEvidence> generate({
    required String text,
    required List<String> localFlags,
    required List<ScamShieldUrlFinding> urlFindings,
  }) {
    final out = <ScamEvidence>[];
    for (final pack in ScamPatternPackLoader.cache) {
      if (!pack.verified) continue;
      if (localFlags.contains(pack.localFlag)) {
        out.add(_fromPack(pack));
      }
    }

    if (localFlags.contains('ss_flag_fake_fine_toll') ||
        (ScamPatternPackDetector.detectFakeFineToll(
          text: text,
          urlFindings: urlFindings,
        ) &&
            _packVerified('fake_fine_toll'))) {
      out.add(
        const ScamEvidence(
          kind: ScamEvidenceKind.fakeFineToll,
          priority: patternPriority,
          textKey: 'ss_evidence_fake_fine_toll',
          sourceLabel: 'Pattern check',
        ),
      );
    }
    return out;
  }

  static bool _packVerified(String id) {
    final packs = ScamPatternPackLoader.cache;
    return packs.any((p) => p.id == id && p.verified);
  }

  static ScamEvidence _fromPack(ScamPatternPack pack) {
    final kind = switch (pack.evidenceKind) {
      ScamPatternEvidenceKind.recoveryOffer => ScamEvidenceKind.recoveryOffer,
      ScamPatternEvidenceKind.payToEarnTask => ScamEvidenceKind.payToEarnTask,
      ScamPatternEvidenceKind.fakeFineToll => ScamEvidenceKind.fakeFineToll,
      ScamPatternEvidenceKind.oneRingCallback =>
        ScamEvidenceKind.oneRingCallback,
      ScamPatternEvidenceKind.investmentOffer =>
        ScamEvidenceKind.investmentOfferSign,
    };
    final priority = switch (pack.evidenceKind) {
      ScamPatternEvidenceKind.recoveryOffer => recoveryPriority,
      ScamPatternEvidenceKind.investmentOffer => 750,
      _ => patternPriority,
    };
    return ScamEvidence(
      kind: kind,
      priority: priority,
      textKey: pack.evidenceTextKey,
      sourceLabel: pack.sourceLabel,
      sourceUrl: pack.sourceUrl,
    );
  }
}
