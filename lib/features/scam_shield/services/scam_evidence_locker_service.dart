import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_response_priority_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Builds and stores local evidence manifests; links user to Document Vault / Scanner.
class ScamEvidenceLockerService {
  ScamEvidenceLockerService({ScamEvidenceRepository? repository})
      : _repository = repository ?? ScamEvidenceRepository.instance;

  final ScamEvidenceRepository _repository;

  Future<ScamEvidenceRecord> saveFromAssessment({
    required ScamShieldAssessmentResult result,
    required String maskedInput,
    String? historyEntryId,
  }) {
    final checklist = [...result.scanAnalysis.recommendedActionKeys];
    if (result.scanAnalysis.stop.triggered &&
        !checklist.contains('ss_action_preserve_evidence')) {
      checklist.insert(0, 'ss_action_preserve_evidence');
    }

    final record = ScamEvidenceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      sourceKind: ScamEvidenceSourceKind.scan,
      maskedSummary: _buildScanSummary(result, maskedInput),
      checklistKeys: checklist,
      historyEntryId: historyEntryId,
      attackStage: result.scanAnalysis.attackStage,
      responseLevel: _responseLevelForStage(result.scanAnalysis.attackStage),
    );
    return _repository.save(record).then((_) => record);
  }

  Future<ScamEvidenceRecord> saveFromIncident({
    required ScamIncidentAssessmentResult result,
    required ScamIncidentInput input,
    String? historyEntryId,
  }) {
    final record = ScamEvidenceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      sourceKind: ScamEvidenceSourceKind.incident,
      maskedSummary: _buildIncidentSummary(result, input),
      checklistKeys: result.checklistActionKeys,
      incidentGroupId: result.incidentGroupId,
      historyEntryId: historyEntryId,
      attackStage: result.stage,
      responseLevel: result.responseLevel,
    );
    return _repository.save(record).then((_) => record);
  }

  Future<ScamEvidenceRecord> saveFromInCallUserNote({
    required String callerNumberTyped,
    required String claimedLabelKey,
    required String locale,
  }) {
    final maskedNumber = callerNumberTyped.isEmpty
        ? '(not provided)'
        : _maskTypedPhone(callerNumberTyped);
    final claimed = ScamShieldStrings.t(claimedLabelKey, locale);
    final record = ScamEvidenceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      sourceKind: ScamEvidenceSourceKind.inCallNote,
      maskedSummary: [
        'Self-attested suspicious call note',
        'Time: ${DateTime.now().toIso8601String()}',
        'They claimed: $claimed',
        'Number typed by user: $maskedNumber',
      ].join('\n'),
      checklistKeys: const ['ss_action_preserve_evidence'],
    );
    return _repository.save(record).then((_) => record);
  }

  Future<List<ScamEvidenceRecord>> loadAll() => _repository.loadAll();

  static String exportText(ScamEvidenceRecord record) {
    final buffer = StringBuffer()
      ..writeln('Raabta Scam Shield — Evidence summary')
      ..writeln('Created: ${record.createdAt.toIso8601String()}')
      ..writeln('Source: ${record.sourceKind.name}');
    if (record.incidentGroupId != null) {
      buffer.writeln('Incident group: ${record.incidentGroupId}');
    }
    if (record.attackStage != null) {
      buffer.writeln('Stage: ${record.attackStage!.name}');
    }
    if (record.responseLevel != null) {
      buffer.writeln('Response: ${record.responseLevel!.name}');
    }
    buffer
      ..writeln('')
      ..writeln(record.maskedSummary)
      ..writeln('')
      ..writeln('— Masked local export. Verify through official channels.');
    return buffer.toString();
  }

  static String _buildScanSummary(
    ScamShieldAssessmentResult result,
    String maskedInput,
  ) {
    final lines = <String>[
      'Risk: ${result.overallRisk.name}',
      'Trust: ${result.scanAnalysis.trustLabel.name}',
      if (result.scanAnalysis.transactionAnomalies.hasAnomalies)
        'Transaction flags: ${result.scanAnalysis.transactionAnomalies.anomalies.map((a) => a.kind.name).join(', ')}',
      '',
      'Masked content:',
      ScamSensitiveInputMask.mask(maskedInput),
    ];
    return lines.join('\n');
  }

  static String _buildIncidentSummary(
    ScamIncidentAssessmentResult result,
    ScamIncidentInput input,
  ) {
    return [
      'Stage: ${result.stage.name}',
      'Level: ${result.responseLevel.name}',
      'Impersonation: ${input.impersonationCategory.name}',
      'Shared: ${input.sharedData.map((e) => e.name).join(', ')}',
      'Outcomes: ${input.outcomes.map((e) => e.name).join(', ')}',
      if (input.freeTextNotes != null && input.freeTextNotes!.trim().isNotEmpty)
        'Notes: ${ScamSensitiveInputMask.mask(input.freeTextNotes!)}',
    ].join('\n');
  }

  static String _maskTypedPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return '••••';
    return '•••• ${digits.substring(digits.length - 4)}';
  }

  static ScamIncidentResponseLevel? _responseLevelForStage(ScamAttackStage stage) {
    const input = ScamIncidentInput();
    final chainConfidence = ScamResponsePriorityEngine.calculateChainConfidence(
      input: input,
    );
    final priority = ScamResponsePriorityEngine.calculatePriority(
      input: input,
      stage: stage,
      chainConfidence: chainConfidence,
    );
    return ScamResponsePriorityEngine.checklistLevelFor(priority);
  }
}
