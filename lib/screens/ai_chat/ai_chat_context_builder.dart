import 'package:raabta/screens/ai_chat/models/ai_chat_context.dart';

abstract final class AiChatContextBuilder {
  static AiChatContext fromDocumentVault(Map<String, dynamic> documentData) {
    final docType = documentData['docType'] as String? ?? 'Document';
    final ocrText = documentData['ocrText'] as String? ?? '';
    final aiSummary = documentData['aiSummary'] as String? ?? '';
    final body = '''
Document type: $docType
Holder name: ${documentData['holderName'] ?? 'N/A'}
Document number: ${documentData['documentNumber'] ?? 'N/A'}
Expiry date: ${documentData['expiryDate'] ?? 'N/A'}
AI summary: ${aiSummary.isEmpty ? 'N/A' : aiSummary}
OCR excerpt: ${ocrText.isEmpty ? 'N/A' : (ocrText.length > 2000 ? ocrText.substring(0, 2000) : ocrText)}
''';

    return AiChatContext(
      source: AiChatContextSource.vault,
      label: docType.replaceAll('_', ' '),
      body: body.trim(),
    );
  }

  static AiChatContext fromVisaGuide({
    required String guideTitle,
    required String stepTitle,
    required int stepNumber,
    required List<String> documents,
  }) {
    return AiChatContext(
      source: AiChatContextSource.visa,
      label: guideTitle,
      body:
          'Visa guide step $stepNumber: "$stepTitle". Documents: ${documents.join(", ")}.',
    );
  }

  static List<String> suggestedVaultQuestions(String docType) {
    switch (docType.toLowerCase()) {
      case 'qid':
        return [
          'When does my QID expire?',
          'What do I need to renew my QID?',
          'Can I travel with an expiring QID?',
        ];
      case 'visa':
        return [
          'Is my visa about to expire?',
          'What happens if my visa expires?',
          'How do I renew my visa in Qatar?',
        ];
      case 'labourcard':
      case 'labour_card':
        return [
          'What are my rights with this labour card?',
          'Can my employer cancel this without notice?',
          'What is the Labour Law article for this?',
        ];
      default:
        return [
          'Summarize this document',
          'Are there any important dates?',
          'What do I need to do with this?',
        ];
    }
  }
}
