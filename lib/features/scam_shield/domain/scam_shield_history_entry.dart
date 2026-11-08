import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/services/scam_sim_swap_service.dart';

/// On-device scan / incident log entry — never synced to Firestore.
class ScamShieldHistoryEntry {
  const ScamShieldHistoryEntry({
    required this.id,
    required this.scannedAt,
    required this.kind,
    required this.riskLevel,
    required this.redFlagSummary,
    required this.inputPreview,
    this.contentType,
    this.attackStage,
    this.responseLevel,
    this.incidentGroupId,
    this.impersonationCategory,
    this.selfReportAnswers,
    this.evidenceKinds = const [],
  });

  final String id;
  final DateTime scannedAt;
  final ScamShieldHistoryEntryKind kind;
  final ScamShieldContentType? contentType;
  final ScamShieldRiskLevel riskLevel;
  final List<String> redFlagSummary;
  final String inputPreview;
  final ScamAttackStage? attackStage;
  final ScamIncidentResponseLevel? responseLevel;
  final String? incidentGroupId;
  final ScamImpersonationCategory? impersonationCategory;
  final SimSwapSelfReportAnswers? selfReportAnswers;
  final List<String> evidenceKinds;

  static const previewMaxLength = 120;
  static const summaryMaxFlags = 5;

  factory ScamShieldHistoryEntry.fromAssessment({
    required ScamShieldAssessmentResult result,
    required String inputText,
    List<String> evidenceKinds = const [],
  }) {
    return ScamShieldHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedAt: DateTime.now(),
      kind: ScamShieldHistoryEntryKind.scan,
      contentType: result.contentType,
      riskLevel: result.overallRisk,
      redFlagSummary: result.redFlags.take(summaryMaxFlags).toList(),
      inputPreview: _preview(inputText),
      evidenceKinds: evidenceKinds,
    );
  }

  factory ScamShieldHistoryEntry.fromSimSwap({
    required SimSwapAssessmentResult result,
    required ScamQatarTelecomProvider provider,
    required SimSwapSelfReportAnswers answers,
  }) {
    final summary = [
      result.analysis.selfReportUrgency.summaryKey,
      ...answers.answeredEntries
          .where((e) => e.value == SimSwapTriStateAnswer.yes)
          .map((e) => e.key.labelKey),
    ].take(summaryMaxFlags).toList();

    return ScamShieldHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedAt: DateTime.now(),
      kind: ScamShieldHistoryEntryKind.simSwap,
      riskLevel: result.analysis.band.displaySeverity,
      redFlagSummary: summary,
      inputPreview: _preview(_simSwapPreview(provider, answers)),
      attackStage: result.analysis.attackStage,
      responseLevel: result.analysis.responseLevel,
      incidentGroupId: result.incidentGroupId,
      selfReportAnswers: answers,
    );
  }

  static String _simSwapPreview(
    ScamQatarTelecomProvider provider,
    SimSwapSelfReportAnswers answers,
  ) {
    final parts = answers.answeredEntries
        .map((e) => '${e.key.name}:${e.value.name}')
        .join(', ');
    return '${provider.name}: $parts';
  }

  factory ScamShieldHistoryEntry.fromIncident({
    required ScamIncidentAssessmentResult result,
    required ScamIncidentInput input,
  }) {
    final summary = [
      ...result.stageSummaryKeys,
      ...result.compoundRisk.reasonKeys,
      if (input.simSelfReportAnswers != null &&
          input.simSelfReportAnswers!.yesCount >= 2)
        SimSwapSelfReportMapper.urgencyFor(input.simSelfReportAnswers!.yesCount)
            .summaryKey,
    ].take(summaryMaxFlags).toList();

    return ScamShieldHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedAt: DateTime.now(),
      kind: ScamShieldHistoryEntryKind.incident,
      riskLevel: result.displaySeverity,
      redFlagSummary: summary,
      inputPreview: _preview(_incidentPreview(input)),
      attackStage: result.stage,
      responseLevel: result.responseLevel,
      incidentGroupId: result.incidentGroupId,
      impersonationCategory: input.impersonationCategory,
      selfReportAnswers: input.simSelfReportAnswers,
    );
  }

  static String _incidentPreview(ScamIncidentInput input) {
    final parts = <String>[
      input.impersonationCategory.name,
      ...input.sharedData.map((e) => e.name),
      ...input.outcomes.map((e) => e.name),
    ];
    return _preview(parts.join(', '));
  }

  static String _preview(String text) {
    final collapsed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= previewMaxLength) return collapsed;
    return '${collapsed.substring(0, previewMaxLength - 1)}…';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scannedAt': scannedAt.toIso8601String(),
        'kind': kind.name,
        'contentType': contentType?.name,
        'riskLevel': riskLevel.name,
        'redFlagSummary': redFlagSummary,
        'inputPreview': inputPreview,
        'attackStage': attackStage?.name,
        'responseLevel': responseLevel?.name,
        'incidentGroupId': incidentGroupId,
        'impersonationCategory': impersonationCategory?.name,
        if (selfReportAnswers != null)
          'selfReportAnswers': selfReportAnswers!.toJson(),
        'evidenceKinds': evidenceKinds,
      };

  factory ScamShieldHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ScamShieldHistoryEntry(
      id: json['id'] as String? ?? '',
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      kind: ScamShieldHistoryEntryKind.values.firstWhere(
        (e) => e.name == json['kind'],
        orElse: () => ScamShieldHistoryEntryKind.scan,
      ),
      contentType: json['contentType'] == null
          ? null
          : ScamShieldContentType.values.firstWhere(
              (e) => e.name == json['contentType'],
              orElse: () => ScamShieldContentType.whatsAppSms,
            ),
      riskLevel: ScamShieldRiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => ScamShieldRiskLevel.low,
      ),
      redFlagSummary: (json['redFlagSummary'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      inputPreview: json['inputPreview'] as String? ?? '',
      attackStage: json['attackStage'] == null
          ? null
          : ScamAttackStage.values.firstWhere(
              (e) => e.name == json['attackStage'],
              orElse: () => ScamAttackStage.contact,
            ),
      responseLevel: json['responseLevel'] == null
          ? null
          : ScamIncidentResponseLevel.values.firstWhere(
              (e) => e.name == json['responseLevel'],
              orElse: () => ScamIncidentResponseLevel.level1,
            ),
      incidentGroupId: json['incidentGroupId'] as String?,
      impersonationCategory: json['impersonationCategory'] == null
          ? null
          : ScamImpersonationCategory.values.firstWhere(
              (e) => e.name == json['impersonationCategory'],
            ),
      selfReportAnswers: json['selfReportAnswers'] == null
          ? null
          : SimSwapSelfReportAnswers.fromJson(
              Map<String, dynamic>.from(
                json['selfReportAnswers'] as Map,
              ),
            ),
      evidenceKinds: (json['evidenceKinds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
