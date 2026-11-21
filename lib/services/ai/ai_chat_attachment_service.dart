import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_attachment.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class AiChatAttachmentService {
  AiChatAttachmentService(this._ocr, this._extraction);

  final ScannerOcrService _ocr;
  final DocumentExtractionService _extraction;
  final ImagePicker _picker = ImagePicker();

  Future<AiChatAttachment?> pickAndProcess({
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null) return null;

    final ocrText = await _ocr.extractText(file.path);
    if (ocrText.trim().isEmpty) {
      return AiChatAttachment(
        fileName: file.name,
        ocrExcerpt: '(No readable text found in image — describe the document in your message.)',
      );
    }

    final classification = await _extraction.extractDocumentData(ocrText);
    return AiChatAttachmentFactory.fromClassification(
      fileName: file.name,
      ocrText: ocrText,
      result: classification,
    );
  }
}
