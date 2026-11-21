import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';
import 'package:raabta/services/documents/document_extraction_config.dart';
import 'package:raabta/services/documents/parsers/booking_confirmation_parser.dart';
import 'package:raabta/services/documents/parsers/bill_provider_parser.dart';
import 'package:raabta/services/documents/parsers/driving_license_parser.dart';
import 'package:raabta/services/documents/parsers/mrz_passport_parser.dart';
import 'package:raabta/services/documents/parsers/qid_parser.dart';
import 'package:raabta/services/documents/parsers/receipt_parser.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// Outcome of a local parse attempt before Claude fallback.
class LocalParseOutcome<T> {
  const LocalParseOutcome({
    this.result,
    required this.confidence,
    required this.documentType,
    this.fallbackReason,
  });

  final T? result;
  final double confidence;
  final String documentType;
  final String? fallbackReason;

  bool get meetsThreshold =>
      result != null &&
      confidence >= DocumentExtractionConfig.localExtractionConfidenceThreshold;
}

/// On-device structured extraction layer — runs before ClaudeAIService.
class LocalDocumentParser {
  LocalDocumentParser._();

  static const _unstructuredKeywords = [
    'employment contract',
    'agreement',
    'certificate',
    'medical report',
    'insurance policy',
    'bank statement',
    'transcript',
    'diploma',
    'offer letter',
    'عقد',
    'شهادة',
    'تأمين',
    'تقرير طبي',
  ];

  static LocalParseOutcome<DocClassificationResult> parseClassification(
    String ocrText,
  ) {
    final text = OcrTextUtils.normalize(ocrText);
    if (text.trim().isEmpty) {
      return const LocalParseOutcome(
        confidence: 0,
        documentType: 'empty',
        fallbackReason: 'empty_ocr',
      );
    }

    if (_isUnstructuredForLocalExtraction(text)) {
      return const LocalParseOutcome(
        confidence: 0,
        documentType: 'unstructured',
        fallbackReason: 'unstructured_claude_only',
      );
    }

    final mrz = MrzPassportParser.parse(text);
    if (mrz != null &&
        mrz.confidence >= DocumentExtractionConfig.localExtractionConfidenceThreshold &&
        mrz.passportNumber != null) {
      return LocalParseOutcome(
        result: DocClassificationResult(
          docType: DocType.passport,
          expiryDate: mrz.expiryDate,
          documentNumber: mrz.passportNumber,
          holderName: mrz.holderName,
          confidence: mrz.confidence,
        ),
        confidence: mrz.confidence,
        documentType: 'passport_mrz',
      );
    }

    final qid = QidParser.parse(text);
    if (qid != null &&
        qid.checkDigitValid &&
        qid.qidNumber != null &&
        qid.confidence >= DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return LocalParseOutcome(
        result: DocClassificationResult(
          docType: DocType.qid,
          expiryDate: qid.expiryDate,
          documentNumber: qid.qidNumber,
          holderName: qid.holderName,
          confidence: qid.confidence,
        ),
        confidence: qid.confidence,
        documentType: 'qid',
      );
    }

    final license = DrivingLicenseParser.parse(text);
    if (license != null &&
        license.licenseNumber != null &&
        license.confidence >=
            DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return LocalParseOutcome(
        result: DocClassificationResult(
          docType: DocType.drivingLicense,
          expiryDate: license.expiryDate,
          documentNumber: license.licenseNumber,
          holderName: license.holderName,
          confidence: license.confidence,
        ),
        confidence: license.confidence,
        documentType: 'driving_license',
      );
    }

    String? reason = 'no_local_match';
    if (mrz != null && !mrz.checkDigitsValid && mrz.confidence < 0.85) {
      reason = 'mrz_check_digit_failed';
    } else if (qid != null && !qid.checkDigitValid) {
      reason = 'qid_check_digit_failed';
    }

    return LocalParseOutcome(
      confidence: mrz?.confidence ?? qid?.confidence ?? license?.confidence ?? 0,
      documentType: mrz != null
          ? 'passport_mrz_invalid'
          : qid != null
              ? 'qid_low_confidence'
              : license != null
                  ? 'driving_license_low_confidence'
                  : 'unknown',
      fallbackReason: reason,
    );
  }

  static LocalParseOutcome<BillExtractionResult> parseBill(String ocrText) {
    final parsed = BillProviderParser.parse(ocrText);
    if (parsed == null) {
      return const LocalParseOutcome(
        confidence: 0,
        documentType: 'bill',
        fallbackReason: 'no_provider_template_match',
      );
    }

    final hasCoreFields = parsed.amount != null &&
        (parsed.dueDate != null ||
            (parsed.accountNumber != null && parsed.accountNumber!.isNotEmpty));

    if (!hasCoreFields ||
        parsed.confidence <
            DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return LocalParseOutcome(
        confidence: parsed.confidence,
        documentType: parsed.provider ?? 'bill',
        fallbackReason: 'bill_incomplete_or_low_confidence',
      );
    }

    final providerMeta = parsed.provider != null
        ? QatarBillProviders.byName(parsed.provider!)
        : null;

    return LocalParseOutcome(
      result: BillExtractionResult(
        provider: parsed.provider,
        billType: providerMeta?.category,
        amount: parsed.amount,
        dueDate: parsed.dueDate,
        accountNumber: parsed.accountNumber,
        currency: parsed.amount != null ? 'QAR' : null,
        confidence: parsed.confidence,
      ),
      confidence: parsed.confidence,
      documentType: parsed.provider ?? 'bill',
    );
  }

  static LocalParseOutcome<ReceiptExtractionResult> parseReceipt(String ocrText) {
    final parsed = ReceiptParser.parse(ocrText);
    if (parsed == null) {
      return const LocalParseOutcome(
        confidence: 0,
        documentType: 'receipt',
        fallbackReason: 'receipt_no_heuristic_match',
      );
    }

    if (parsed.confidence <
        DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return LocalParseOutcome(
        confidence: parsed.confidence,
        documentType: 'receipt',
        fallbackReason: 'receipt_low_confidence',
      );
    }

    return LocalParseOutcome(
      result: ReceiptExtractionResult(
        productName: parsed.productName,
        purchaseDate: parsed.purchaseDate,
        store: parsed.store,
        price: parsed.price,
        warrantyPeriodGuessMonths: parsed.warrantyPeriodGuessMonths,
        confidence: parsed.confidence,
      ),
      confidence: parsed.confidence,
      documentType: 'receipt',
    );
  }

  static LocalParseOutcome<BookingConfirmationExtractionResult>
      parseBookingConfirmation(String ocrText) {
    final parsed = BookingConfirmationParser.parse(ocrText);
    if (parsed == null) {
      return const LocalParseOutcome(
        confidence: 0,
        documentType: 'booking_confirmation',
        fallbackReason: 'booking_no_heuristic_match',
      );
    }

    final result = BookingConfirmationExtractionResult(
      bookingType: parsed.bookingType,
      destinationCity: parsed.destinationCity,
      destinationCountry: parsed.destinationCountry,
      startDateTime: parsed.startDateTime,
      endDateTime: parsed.endDateTime,
      confirmationNumber: parsed.confirmationNumber,
      providerName: parsed.providerName,
      guestName: parsed.guestName,
      confidence: parsed.confidence,
      fieldConfidence: parsed.fieldConfidence,
    );

    if (parsed.confidence <
        DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return LocalParseOutcome(
        result: result,
        confidence: parsed.confidence,
        documentType: parsed.bookingType?.name ?? 'booking_confirmation',
        fallbackReason: 'booking_low_confidence',
      );
    }

    return LocalParseOutcome(
      result: result,
      confidence: parsed.confidence,
      documentType: parsed.bookingType?.name ?? 'booking_confirmation',
    );
  }

  static bool _isUnstructuredForLocalExtraction(String text) {
    final lower = text.toLowerCase();
    final hits =
        _unstructuredKeywords.where((k) => lower.contains(k.toLowerCase())).length;
    if (hits >= 2) return true;
    if (hits == 1 && text.length > 800) return true;
    return false;
  }
}
