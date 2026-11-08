import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_coordinator.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_engine.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';

/// Evidence kinds + anonymous signal queue (opt-in only).
abstract final class ScamAnonymousSignalHelpers {
  static Future<List<String>> evidenceKindNames({
    required WidgetRef ref,
    required String text,
    required String locale,
    required ScamShieldAssessmentResult result,
    required ScamMessageSenderType senderType,
  }) async {
    return ScamEvidenceEngine.compute(
      EvidenceEngineInput(
        text: text,
        locale: locale,
        localFlags: result.localCheck.redFlags,
        urlFindings: result.urlFindings,
        senderType: senderType,
        advisories: ref.read(scamAdvisoryCatalogProvider),
        attackStage: result.scanAnalysis.attackStage,
      ),
    ).map((e) => e.kind.name).toList();
  }

  static Future<void> afterAssessmentShown({
    required WidgetRef ref,
    required String text,
    required String locale,
    required ScamShieldAssessmentResult result,
    required ScamMessageSenderType senderType,
    required List<String> evidenceKindNames,
  }) async {
    unawaited(
      ScamAnonymousSignalCoordinator.onAssessmentResultShown(
        result: result,
        sourceTextForLocalClassification: text,
        evidenceKindNames: evidenceKindNames,
        locale: locale,
        senderType: senderType,
      ),
    );
  }

  static Future<void> bootstrapUploadIfOptedIn() async {
    unawaited(ScamAnonymousSignalCoordinator.flushIfDue());
  }
}
