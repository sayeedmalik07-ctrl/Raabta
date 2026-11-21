import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

enum ScamEvidenceSourceKind { scan, incident, simSwap, inCallNote }

/// Local-only evidence manifest — masked text, never raw credentials.
class ScamEvidenceRecord {
  const ScamEvidenceRecord({
    required this.id,
    required this.createdAt,
    required this.sourceKind,
    required this.maskedSummary,
    required this.checklistKeys,
    this.incidentGroupId,
    this.historyEntryId,
    this.attackStage,
    this.responseLevel,
    this.vaultDocumentId,
  });

  final String id;
  final DateTime createdAt;
  final ScamEvidenceSourceKind sourceKind;
  final String maskedSummary;
  final List<String> checklistKeys;
  final String? incidentGroupId;
  final String? historyEntryId;
  final ScamAttackStage? attackStage;
  final ScamIncidentResponseLevel? responseLevel;
  final String? vaultDocumentId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'sourceKind': sourceKind.name,
        'maskedSummary': maskedSummary,
        'checklistKeys': checklistKeys,
        'incidentGroupId': incidentGroupId,
        'historyEntryId': historyEntryId,
        'attackStage': attackStage?.name,
        'responseLevel': responseLevel?.name,
        'vaultDocumentId': vaultDocumentId,
      };

  factory ScamEvidenceRecord.fromJson(Map<String, dynamic> json) {
    return ScamEvidenceRecord(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      sourceKind: ScamEvidenceSourceKind.values.firstWhere(
        (e) => e.name == json['sourceKind'],
        orElse: () => ScamEvidenceSourceKind.scan,
      ),
      maskedSummary: json['maskedSummary'] as String? ?? '',
      checklistKeys: (json['checklistKeys'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      incidentGroupId: json['incidentGroupId'] as String?,
      historyEntryId: json['historyEntryId'] as String?,
      attackStage: json['attackStage'] == null
          ? null
          : ScamAttackStage.values.firstWhere(
              (e) => e.name == json['attackStage'],
            ),
      responseLevel: json['responseLevel'] == null
          ? null
          : ScamIncidentResponseLevel.values.firstWhere(
              (e) => e.name == json['responseLevel'],
            ),
      vaultDocumentId: json['vaultDocumentId'] as String?,
    );
  }

  ScamEvidenceRecord copyWithVaultLink(String vaultDocumentId) {
    return ScamEvidenceRecord(
      id: id,
      createdAt: createdAt,
      sourceKind: sourceKind,
      maskedSummary: maskedSummary,
      checklistKeys: checklistKeys,
      incidentGroupId: incidentGroupId,
      historyEntryId: historyEntryId,
      attackStage: attackStage,
      responseLevel: responseLevel,
      vaultDocumentId: vaultDocumentId,
    );
  }
}
