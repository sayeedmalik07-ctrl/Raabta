import 'package:raabta/services/ai/document_extraction_service.dart';

/// Pending document/image attached to a chat message before send.
class AiChatAttachment {
  const AiChatAttachment({
    required this.fileName,
    required this.ocrExcerpt,
    this.docType,
    this.holderName,
    this.documentNumber,
    this.expiryDate,
  });

  final String fileName;
  final String ocrExcerpt;
  final String? docType;
  final String? holderName;
  final String? documentNumber;
  final DateTime? expiryDate;

  String get contextBlock {
    final buffer = StringBuffer('Attached document: $fileName');
    if (docType != null) buffer.write('\nType: $docType');
    if (holderName != null) buffer.write('\nHolder: $holderName');
    if (documentNumber != null) buffer.write('\nNumber: $documentNumber');
    if (expiryDate != null) {
      buffer.write('\nExpiry: ${expiryDate!.toIso8601String().split('T').first}');
    }
    buffer.write('\nOCR excerpt:\n$ocrExcerpt');
    return buffer.toString();
  }
}

abstract final class AiChatAttachmentFactory {
  static AiChatAttachment fromClassification({
    required String fileName,
    required String ocrText,
    required DocClassificationResult result,
  }) {
    final excerpt = ocrText.length > 2500
        ? '${ocrText.substring(0, 2500)}…'
        : ocrText;
    return AiChatAttachment(
      fileName: fileName,
      ocrExcerpt: excerpt,
      docType: result.docType.name,
      holderName: result.holderName,
      documentNumber: result.documentNumber,
      expiryDate: result.expiryDate,
    );
  }
}
