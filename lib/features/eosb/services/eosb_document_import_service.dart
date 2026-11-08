import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/services/eosb_document_quality_gate.dart';
import 'package:raabta/features/eosb/services/eosb_contract_analysis_service.dart';

/// Imports employment data from OCR text or document vault content.
class EosbDocumentImportService {
  EosbDocumentImportService(this._analysis);

  final EosbContractAnalysisService _analysis;

  Future<EosbContractAnalysis> importFromText({
    required String ocrText,
    required String documentKind,
    required String language,
    double? ocrConfidence,
  }) {
    final quality = EosbDocumentQualityGate.evaluate(
      text: ocrText,
      documentKind: documentKind,
      ocrConfidence: ocrConfidence,
    );

    if (!quality.isAcceptable) {
      return Future.value(
        EosbContractAnalysis(
          warnings: [
            quality.rejectionReasonKey ?? 'eosb_contract_quality_short',
          ],
          confidence: quality.qualityScore,
        ),
      );
    }

    return _analysis.analyzeDocumentText(
      documentText: ocrText,
      documentKind: documentKind,
      language: language,
    );
  }

  static const supportedDocumentKinds = [
    'Employment Contract',
    'Offer Letter',
    'Salary Slip',
    'Settlement Letter',
    'Termination Letter',
    'Resignation Letter',
    'Leave Report',
  ];
}
