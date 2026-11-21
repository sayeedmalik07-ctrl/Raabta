import 'dart:developer' as developer;

/// Cost-visibility logging for document extraction routing decisions.
class DocumentExtractionRoutingLog {
  DocumentExtractionRoutingLog._();

  static void localHit({
    required String extractionKind,
    required String documentType,
    required double confidence,
    String? detail,
  }) {
    developer.log(
      'docScannerLocalHit '
      'kind=$extractionKind '
      'type=$documentType '
      'confidence=${confidence.toStringAsFixed(2)}'
      '${detail != null ? ' $detail' : ''}',
      name: 'DocumentExtraction',
    );
  }

  static void claudeFallback({
    required String extractionKind,
    required String reason,
    String? documentType,
    double? localConfidence,
  }) {
    developer.log(
      'docScannerClaudeFallback '
      'kind=$extractionKind '
      'reason=$reason'
      '${documentType != null ? ' type=$documentType' : ''}'
      '${localConfidence != null ? ' localConfidence=${localConfidence.toStringAsFixed(2)}' : ''}',
      name: 'DocumentExtraction',
    );
  }
}
