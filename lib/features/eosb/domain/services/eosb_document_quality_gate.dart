/// Lightweight OCR quality gate before sending contract text to Claude.
class EosbDocumentQualityResult {
  const EosbDocumentQualityResult({
    required this.isAcceptable,
    required this.qualityScore,
    this.rejectionReasonKey,
  });

  final bool isAcceptable;
  final double qualityScore;
  final String? rejectionReasonKey;
}

abstract final class EosbDocumentQualityGate {
  static const minCharsFullDocument = 150;
  static const minCharsShortDocument = 80;
  static const minWordCount = 25;
  static const minAlphaNumericRatio = 0.55;
  static const minOcrConfidence = 0.65;

  static const _shortDocumentKinds = {
    'Salary Slip',
    'Leave Report',
  };

  static EosbDocumentQualityResult evaluate({
    required String text,
    required String documentKind,
    double? ocrConfidence,
  }) {
    final trimmed = text.trim();
    final minChars = _shortDocumentKinds.contains(documentKind)
        ? minCharsShortDocument
        : minCharsFullDocument;

    if (trimmed.length < minChars) {
      return const EosbDocumentQualityResult(
        isAcceptable: false,
        qualityScore: 0,
        rejectionReasonKey: 'eosb_contract_quality_short',
      );
    }

    final words =
        trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words < minWordCount) {
      return const EosbDocumentQualityResult(
        isAcceptable: false,
        qualityScore: 0.2,
        rejectionReasonKey: 'eosb_contract_quality_words',
      );
    }

    final alphaNumeric = RegExp(r'[A-Za-z0-9]').allMatches(trimmed).length;
    final ratio = alphaNumeric / trimmed.length;
    if (ratio < minAlphaNumericRatio) {
      return EosbDocumentQualityResult(
        isAcceptable: false,
        qualityScore: ratio,
        rejectionReasonKey: 'eosb_contract_quality_garbled',
      );
    }

    if (ocrConfidence != null && ocrConfidence < minOcrConfidence) {
      return EosbDocumentQualityResult(
        isAcceptable: false,
        qualityScore: ocrConfidence,
        rejectionReasonKey: 'eosb_contract_quality_ocr',
      );
    }

    final score = (ratio * 0.6) +
        (words.clamp(0, 100) / 100 * 0.3) +
        ((ocrConfidence ?? 0.85) * 0.1);

    return EosbDocumentQualityResult(
      isAcceptable: true,
      qualityScore: score.clamp(0.0, 1.0),
    );
  }
}
