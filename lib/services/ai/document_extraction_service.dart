import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/documents/document_extraction_routing_log.dart';
import 'package:raabta/services/documents/local_document_parser.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_planner_config.dart';
import 'package:raabta/services/documents/parsers/bill_provider_parser.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';

// ─── RESULT MODEL ───────────────────────────────────────

enum DocType {
  qid,
  passport,
  visa,
  labourCard,
  drivingLicense,
  receipt,
  bill,
  labReport,
  prescription,
  medicalCertificate,
  vaccinationRecord,
  healthInsurance,
  healthInsuranceClaim,
  imagingReport,
  bookingConfirmation,
  unknown,
}

class DocClassificationResult {
  const DocClassificationResult({
    required this.docType,
    this.expiryDate,
    this.documentNumber,
    this.holderName,
    required this.confidence,
  });

  final DocType docType;
  final DateTime? expiryDate;
  final String? documentNumber;
  final String? holderName;
  final double confidence;

  factory DocClassificationResult.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpiry;
    final expiryStr = json['expiryDate'] as String?;
    if (expiryStr != null && expiryStr.isNotEmpty) {
      try {
        parsedExpiry = DateTime.parse(expiryStr);
      } catch (_) {
        parsedExpiry = null;
      }
    }

    return DocClassificationResult(
      docType: _parseDocType(json['docType'] as String?),
      expiryDate: parsedExpiry,
      documentNumber: json['documentNumber'] as String?,
      holderName: json['holderName'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static DocType _parseDocType(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'qid':
        return DocType.qid;
      case 'passport':
        return DocType.passport;
      case 'visa':
        return DocType.visa;
      case 'labour_card':
      case 'labourcard':
        return DocType.labourCard;
      case 'driving_license':
      case 'drivinglicense':
        return DocType.drivingLicense;
      case 'receipt':
        return DocType.receipt;
      case 'bill':
        return DocType.bill;
      case 'lab_report':
      case 'labreport':
        return DocType.labReport;
      case 'prescription':
        return DocType.prescription;
      case 'medical_certificate':
      case 'medicalcertificate':
        return DocType.medicalCertificate;
      case 'vaccination_record':
      case 'vaccinationrecord':
        return DocType.vaccinationRecord;
      case 'health_insurance':
      case 'healthinsurance':
        return DocType.healthInsurance;
      case 'health_insurance_claim':
      case 'healthinsuranceclaim':
        return DocType.healthInsuranceClaim;
      case 'imaging_report':
      case 'imagingreport':
        return DocType.imagingReport;
      case 'booking_confirmation':
      case 'bookingconfirmation':
        return DocType.bookingConfirmation;
      default:
        return DocType.unknown;
    }
  }
}

// ─── BILL-SPECIFIC RESULT (used by Bill Tracker) ────────

enum BillExtractionConfidence { high, medium, low }

class BillExtractionResult {
  BillExtractionResult({
    this.provider,
    this.billType,
    this.amount,
    this.dueDate,
    this.accountNumber,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.currency,
    BillExtractionConfidence? confidenceLevel,
    double? confidence,
  })  : confidenceLevel = confidenceLevel ??
            levelFromScore(confidence ?? 0),
        confidence = confidence ?? scoreFromLevel(
              confidenceLevel ?? BillExtractionConfidence.low,
            );

  /// Same as [utilityProvider] — Qatar retailer name when visible on bill.
  final String? provider;
  final String? billType;
  final double? amount;
  final DateTime? dueDate;
  final String? accountNumber;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final String? currency;
  final BillExtractionConfidence confidenceLevel;

  /// Legacy 0.0–1.0 score — derived from [confidenceLevel] when absent in JSON.
  final double confidence;

  String? get utilityProvider => provider;
  double? get amountDue => amount;

  static BillExtractionConfidence levelFromScore(double score) {
    if (score >= 0.65) return BillExtractionConfidence.high;
    if (score >= 0.40) return BillExtractionConfidence.medium;
    return BillExtractionConfidence.low;
  }

  static double scoreFromLevel(BillExtractionConfidence level) {
    return switch (level) {
      BillExtractionConfidence.high => 0.85,
      BillExtractionConfidence.medium => 0.55,
      BillExtractionConfidence.low => 0.25,
    };
  }

  static BillExtractionConfidence? _parseConfidenceLevel(dynamic raw) {
    if (raw is! String) return null;
    return switch (raw.toLowerCase()) {
      'high' => BillExtractionConfidence.high,
      'medium' => BillExtractionConfidence.medium,
      'low' => BillExtractionConfidence.low,
      _ => null,
    };
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      return DateTime.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  factory BillExtractionResult.fromJson(Map<String, dynamic> json) {
    final level = _parseConfidenceLevel(json['confidence']) ??
        levelFromScore((json['confidence'] as num?)?.toDouble() ?? 0);

    final provider = (json['utilityProvider'] as String?)?.trim().isNotEmpty ==
            true
        ? json['utilityProvider'] as String
        : json['provider'] as String?;

    final amountRaw = json['amountDue'] ?? json['amount'];

    return BillExtractionResult(
      provider: provider,
      billType: json['billType'] as String?,
      amount: (amountRaw as num?)?.toDouble(),
      dueDate: _parseDate(json['dueDate']),
      accountNumber: json['accountNumber'] as String?,
      billingPeriodStart: _parseDate(json['billingPeriodStart']),
      billingPeriodEnd: _parseDate(json['billingPeriodEnd']),
      currency: json['currency'] as String?,
      confidenceLevel: level,
    );
  }
}

// ─── RECEIPT LINE ITEMS (Bill Splitter itemized split) ──

enum ReceiptLineItemsConfidence { high, medium, low }

class ReceiptLineItemRow {
  const ReceiptLineItemRow({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  final String name;
  final double price;
  final double quantity;

  double get lineTotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory ReceiptLineItemRow.fromJson(Map<String, dynamic> json) {
    return ReceiptLineItemRow(
      name: (json['name'] as String? ?? '').trim(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
    );
  }

  ReceiptLineItemRow copyWith({
    String? name,
    double? price,
    double? quantity,
  }) {
    return ReceiptLineItemRow(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ReceiptLineItemsExtractionResult {
  const ReceiptLineItemsExtractionResult({
    this.merchant,
    this.date,
    this.currency,
    this.lineItems = const [],
    this.subtotal,
    this.tax,
    this.serviceCharge,
    this.tip,
    this.total,
    this.confidence = ReceiptLineItemsConfidence.low,
  });

  final String? merchant;
  final String? date;
  final String? currency;
  final List<ReceiptLineItemRow> lineItems;
  final double? subtotal;
  final double? tax;
  final double? serviceCharge;
  final double? tip;
  final double? total;
  final ReceiptLineItemsConfidence confidence;

  bool get isLowConfidence => confidence == ReceiptLineItemsConfidence.low;

  int get nullFieldCount => [
        merchant,
        date,
        currency,
        subtotal,
        tax,
        serviceCharge,
        tip,
        total,
      ].where((v) => v == null).length;

  bool get shouldShowReviewWarning =>
      isLowConfidence || nullFieldCount >= 3 || lineItems.isEmpty;

  factory ReceiptLineItemsExtractionResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['lineItems'] as List<dynamic>? ?? [];
    final confidenceRaw =
        (json['confidence'] as String? ?? 'low').trim().toLowerCase();
    final confidence = switch (confidenceRaw) {
      'high' => ReceiptLineItemsConfidence.high,
      'medium' => ReceiptLineItemsConfidence.medium,
      _ => ReceiptLineItemsConfidence.low,
    };

    double? readAmount(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String? readString(dynamic value) {
      if (value == null) return null;
      final s = value.toString().trim();
      return s.isEmpty ? null : s;
    }

    return ReceiptLineItemsExtractionResult(
      merchant: readString(json['merchant']),
      date: readString(json['date']),
      currency: readString(json['currency']),
      lineItems: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(ReceiptLineItemRow.fromJson)
          .where((item) => item.name.isNotEmpty)
          .toList(growable: false),
      subtotal: readAmount(json['subtotal']),
      tax: readAmount(json['tax']),
      serviceCharge: readAmount(json['serviceCharge']),
      tip: readAmount(json['tip']),
      total: readAmount(json['total']),
      confidence: confidence,
    );
  }

  ReceiptLineItemsExtractionResult copyWith({
    String? merchant,
    String? date,
    String? currency,
    List<ReceiptLineItemRow>? lineItems,
    double? subtotal,
    double? tax,
    double? serviceCharge,
    double? tip,
    double? total,
    ReceiptLineItemsConfidence? confidence,
  }) {
    return ReceiptLineItemsExtractionResult(
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      confidence: confidence ?? this.confidence,
    );
  }
}

// ─── WARRANTY RECEIPT (Warranty Shield scan flow) ──

enum WarrantyExtractionConfidence { high, medium, low }

class WarrantyExtractionResult {
  const WarrantyExtractionResult({
    this.itemName,
    this.category,
    this.retailer,
    this.brand,
    this.purchaseDate,
    this.price,
    this.currency,
    this.warrantyDurationMonths,
    this.warrantyExpiryDate,
    this.confidence = WarrantyExtractionConfidence.low,
  });

  final String? itemName;
  final String? category;
  final String? retailer;
  final String? brand;
  final DateTime? purchaseDate;
  final double? price;
  final String? currency;
  final int? warrantyDurationMonths;
  final DateTime? warrantyExpiryDate;
  final WarrantyExtractionConfidence confidence;

  bool get isLowConfidence => confidence == WarrantyExtractionConfidence.low;

  bool get needsExpiryConfirmation =>
      warrantyExpiryDate == null && warrantyDurationMonths == null;

  factory WarrantyExtractionResult.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    }

    WarrantyExtractionConfidence parseConfidence(String? raw) {
      switch (raw?.toLowerCase().trim()) {
        case 'high':
          return WarrantyExtractionConfidence.high;
        case 'medium':
          return WarrantyExtractionConfidence.medium;
        default:
          return WarrantyExtractionConfidence.low;
      }
    }

    return WarrantyExtractionResult(
      itemName: _emptyToNull(json['itemName'] as String?),
      category: _emptyToNull(json['category'] as String?),
      retailer: _emptyToNull(json['retailer'] as String?),
      brand: _emptyToNull(json['brand'] as String?),
      purchaseDate: parseDate(json['purchaseDate'] as String?),
      price: (json['price'] as num?)?.toDouble(),
      currency: _emptyToNull(json['currency'] as String?),
      warrantyDurationMonths:
          (json['warrantyDurationMonths'] as num?)?.toInt(),
      warrantyExpiryDate: parseDate(json['warrantyExpiryDate'] as String?),
      confidence: parseConfidence(json['confidence'] as String?),
    );
  }

  static String? _emptyToNull(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();
}

// ─── RECEIPT-SPECIFIC RESULT (legacy add-sheet widget) ──

class ReceiptExtractionResult {
  const ReceiptExtractionResult({
    this.productName,
    this.purchaseDate,
    this.store,
    this.price,
    this.warrantyPeriodGuessMonths,
    required this.confidence,
  });

  final String? productName;
  final DateTime? purchaseDate;
  final String? store;
  final double? price;
  final int? warrantyPeriodGuessMonths;
  final double confidence;

  factory ReceiptExtractionResult.fromJson(Map<String, dynamic> json) {
    DateTime? parsedPurchase;
    final purchaseStr = json['purchaseDate'] as String?;
    if (purchaseStr != null && purchaseStr.isNotEmpty) {
      try {
        parsedPurchase = DateTime.parse(purchaseStr);
      } catch (_) {
        parsedPurchase = null;
      }
    }
    return ReceiptExtractionResult(
      productName: json['productName'] as String?,
      purchaseDate: parsedPurchase,
      store: json['store'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      warrantyPeriodGuessMonths:
          (json['warrantyPeriodGuess'] as num?)?.toInt(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── BOOKING CONFIRMATION (Trip Planner import) ──

class BookingConfirmationExtractionResult {
  const BookingConfirmationExtractionResult({
    this.bookingType,
    this.destinationCity,
    this.destinationCountry,
    this.startDateTime,
    this.endDateTime,
    this.confirmationNumber,
    this.providerName,
    this.guestName,
    required this.confidence,
    this.fieldConfidence = const {},
  });

  final TripBookingType? bookingType;
  final String? destinationCity;
  final String? destinationCountry;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? confirmationNumber;
  final String? providerName;
  final String? guestName;
  final double confidence;
  final Map<String, double> fieldConfidence;

  bool fieldIsLowConfidence(String field) {
    final c = fieldConfidence[field];
    if (c == null) return true;
    return c < 0.65;
  }

  factory BookingConfirmationExtractionResult.fromJson(
    Map<String, dynamic> json,
  ) {
    DateTime? parseDt(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    TripBookingType? type;
    final typeRaw = (json['bookingType'] as String?)?.trim();
    if (typeRaw != null && typeRaw.isNotEmpty) {
      type = switch (typeRaw.toLowerCase().replaceAll('_', '')) {
        'flight' => TripBookingType.flight,
        'hotel' => TripBookingType.hotel,
        'carrental' => TripBookingType.carRental,
        _ => TripBookingTypeExt.fromKey(typeRaw),
      };
    }

    return BookingConfirmationExtractionResult(
      bookingType: type,
      destinationCity: _emptyToNull(json['destinationCity'] as String?),
      destinationCountry: _emptyToNull(json['destinationCountry'] as String?),
      startDateTime: parseDt(json['startDateTime'] as String?),
      endDateTime: parseDt(json['endDateTime'] as String?),
      confirmationNumber: _emptyToNull(json['confirmationNumber'] as String?),
      providerName: _emptyToNull(json['providerName'] as String?),
      guestName: _emptyToNull(json['guestName'] as String?),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      fieldConfidence: (json['fieldConfidence'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          const {},
    );
  }

  static String? _emptyToNull(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  BookingConfirmationExtractionResult mergePreferLocal(
    BookingConfirmationExtractionResult local,
  ) {
    return BookingConfirmationExtractionResult(
      bookingType: local.bookingType ?? bookingType,
      destinationCity: local.destinationCity ?? destinationCity,
      destinationCountry: local.destinationCountry ?? destinationCountry,
      startDateTime: local.startDateTime ?? startDateTime,
      endDateTime: local.endDateTime ?? endDateTime,
      confirmationNumber: local.confirmationNumber ?? confirmationNumber,
      providerName: local.providerName ?? providerName,
      guestName: local.guestName ?? guestName,
      confidence: confidence,
      fieldConfidence: {...local.fieldConfidence, ...fieldConfidence},
    );
  }
}

// ─── SHARED SERVICE ──────────────────────────────────────

class DocumentExtractionService {
  DocumentExtractionService(this._claudeService);

  final ClaudeAIService _claudeService;
  static bool _billTemplatesLoaded = false;

  Future<void> _ensureBillTemplatesLoaded() async {
    if (_billTemplatesLoaded) return;
    await BillProviderParser.ensureLoaded();
    _billTemplatesLoaded = true;
  }

  Future<DocClassificationResult> extractDocumentData(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      return const DocClassificationResult(
        docType: DocType.unknown,
        confidence: 0.0,
      );
    }

    final local = LocalDocumentParser.parseClassification(ocrText);
    if (local.meetsThreshold && local.result != null) {
      DocumentExtractionRoutingLog.localHit(
        extractionKind: 'document',
        documentType: local.documentType,
        confidence: local.confidence,
      );
      return local.result!;
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'document',
      reason: local.fallbackReason ?? 'below_threshold',
      documentType: local.documentType,
      localConfidence: local.confidence,
    );
    return _extractDocumentDataViaClaude(ocrText);
  }

  Future<BillExtractionResult> extractBillData(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      return BillExtractionResult(confidence: 0.0);
    }

    await _ensureBillTemplatesLoaded();
    final local = LocalDocumentParser.parseBill(ocrText);
    if (local.meetsThreshold && local.result != null) {
      DocumentExtractionRoutingLog.localHit(
        extractionKind: 'bill',
        documentType: local.documentType,
        confidence: local.confidence,
      );
      return local.result!;
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'bill',
      reason: local.fallbackReason ?? 'below_threshold',
      documentType: local.documentType,
      localConfidence: local.confidence,
    );
    return _extractBillDataViaClaude(ocrText);
  }

  Future<ReceiptLineItemsExtractionResult> extractReceiptLineItems(
    String ocrText,
  ) async {
    if (ocrText.trim().isEmpty) {
      return const ReceiptLineItemsExtractionResult();
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'receipt_line_items',
      reason: 'no_local_parser',
      documentType: 'receipt',
      localConfidence: 0,
    );
    return _extractReceiptLineItemsViaClaude(ocrText);
  }

  Future<WarrantyExtractionResult> extractWarrantyData(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      return const WarrantyExtractionResult();
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'warranty_receipt',
      reason: 'no_local_parser',
      documentType: 'receipt',
      localConfidence: 0,
    );
    return _extractWarrantyDataViaClaude(ocrText);
  }

  Future<ReceiptExtractionResult> extractReceiptData(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      return const ReceiptExtractionResult(confidence: 0.0);
    }

    final local = LocalDocumentParser.parseReceipt(ocrText);
    if (local.meetsThreshold && local.result != null) {
      DocumentExtractionRoutingLog.localHit(
        extractionKind: 'receipt',
        documentType: local.documentType,
        confidence: local.confidence,
      );
      return local.result!;
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'receipt',
      reason: local.fallbackReason ?? 'below_threshold',
      documentType: local.documentType,
      localConfidence: local.confidence,
    );
    return _extractReceiptDataViaClaude(ocrText);
  }

  Future<BookingConfirmationExtractionResult> extractBookingConfirmationData(
    String ocrText,
  ) async {
    if (ocrText.trim().isEmpty) {
      return const BookingConfirmationExtractionResult(confidence: 0.0);
    }

    final local = LocalDocumentParser.parseBookingConfirmation(ocrText);
    if (local.meetsThreshold && local.result != null) {
      DocumentExtractionRoutingLog.localHit(
        extractionKind: 'booking_confirmation',
        documentType: local.documentType,
        confidence: local.confidence,
      );
      return local.result!;
    }

    DocumentExtractionRoutingLog.claudeFallback(
      extractionKind: 'booking_confirmation',
      reason: local.fallbackReason ?? 'below_threshold',
      documentType: local.documentType,
      localConfidence: local.confidence,
    );

    final ai = await _extractBookingConfirmationViaClaude(ocrText);
    if (local.result != null) {
      return ai.mergePreferLocal(local.result!);
    }
    return ai;
  }

  Future<DocClassificationResult> _extractDocumentDataViaClaude(
    String ocrText,
  ) async {
    final prompt = '''
You are a document classification expert for Qatar resident
documents. Analyze this OCR-extracted text and identify what
type of document it is.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "docType": "<qid|passport|visa|labour_card|driving_license|unknown>",
  "expiryDate": "<ISO8601 date YYYY-MM-DD if found, else empty string>",
  "documentNumber": "<the ID/document number if found, else empty string>",
  "holderName": "<the person's name if found, else empty string>",
  "confidence": <number 0.0 to 1.0 representing how confident you are>
}

Rules:
- If text is too garbled to identify a document type, use "unknown"
  and confidence below 0.4
- Qatar QID numbers are 11 digits
- Look for Arabic and English date formats
- confidence should reflect both document type certainty AND
  whether expiry date was clearly found
- If multiple dates appear, prioritize the one labeled
  expiry/valid until/تاريخ الانتهاء
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: 'document_extraction',
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return DocClassificationResult.fromJson(json);
    } catch (_) {
      return const DocClassificationResult(
        docType: DocType.unknown,
        confidence: 0.0,
      );
    }
  }

  Future<BillExtractionResult> _extractBillDataViaClaude(String ocrText) async {
    final prompt = '''
You are a bill data extraction expert for Qatar utility bills.
Analyze this OCR-extracted text from a bill photo or PDF.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "utilityProvider": "<$qatarBillProviderClaudeList>",
  "billType": "<e.g. Electricity & Water, Mobile, Internet, District Cooling, or null>",
  "accountNumber": "<account or contract number if clearly printed, else null>",
  "billingPeriodStart": "<ISO8601 YYYY-MM-DD if printed, else null>",
  "billingPeriodEnd": "<ISO8601 YYYY-MM-DD if printed, else null>",
  "amountDue": <number total amount due in QAR, or null if not clearly visible>,
  "currency": "<QAR if amount present, else null>",
  "dueDate": "<ISO8601 YYYY-MM-DD payment due date if printed, else null>",
  "confidence": "<high|medium|low>"
}

Rules:
- Extract ONLY what is visibly printed — never guess due dates, amounts, or periods
- Use confidence "low" if image/PDF is blurry, cropped, or fields are ambiguous
- Use null for any field you cannot read with reasonable certainty
- Amount must reflect total amount due (not previous balance unless that is the only due figure)
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: 'bill_extraction',
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return BillExtractionResult.fromJson(json);
    } catch (_) {
      return BillExtractionResult(confidence: 0.0);
    }
  }

  Future<ReceiptLineItemsExtractionResult> _extractReceiptLineItemsViaClaude(
    String ocrText,
  ) async {
    final prompt = '''
You are a receipt line-item extraction expert for restaurant and retail receipts.
Analyze this OCR-extracted text from a receipt photo.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "merchant": "<store name if visibly printed, else null>",
  "date": "<date string as printed, else null>",
  "currency": "<ISO 4217 code if clearly indicated, else null>",
  "lineItems": [
    { "name": "<item name>", "price": <unit price number>, "quantity": <number> }
  ],
  "subtotal": <number or null>,
  "tax": <number or null>,
  "serviceCharge": <number or null>,
  "tip": <number or null>,
  "total": <number or null>,
  "confidence": "<high|medium|low>"
}

Rules:
- Extract ONLY what is visibly printed on the receipt — never invent items or prices
- Use null (JSON null) for any field you cannot read clearly — do not guess
- Mark confidence "low" if the image text is blurry, cut off, or handwritten
- Mark confidence "medium" if some line items are uncertain
- Mark confidence "high" only when line items and totals are clearly readable
- quantity defaults to 1 when not shown
- lineItems must reflect individual purchasable rows, not summary labels only
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: 'receipt_line_items_extraction',
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return ReceiptLineItemsExtractionResult.fromJson(json);
    } catch (_) {
      return const ReceiptLineItemsExtractionResult();
    }
  }

  Future<WarrantyExtractionResult> _extractWarrantyDataViaClaude(
    String ocrText,
  ) async {
    final prompt = '''
You are extracting product warranty details from a purchase receipt, warranty card, or box label in Qatar.
Analyze this OCR-extracted text from a photo.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "itemName": "<product name if visibly printed, else null>",
  "category": "<Electronics|Appliance|Furniture|Vehicle|General or null>",
  "retailer": "<store/retailer name if found, else null>",
  "brand": "<manufacturer brand if found, else null>",
  "purchaseDate": "<ISO8601 YYYY-MM-DD if found, else null>",
  "price": <number paid if found, else null>,
  "currency": "<ISO4217 code e.g. QAR if found, else null>",
  "warrantyDurationMonths": <integer months ONLY if explicitly printed on the document, else null>,
  "warrantyExpiryDate": "<ISO8601 YYYY-MM-DD ONLY if explicitly printed, else null>",
  "confidence": "<high|medium|low>"
}

Rules:
- Extract ONLY what is visibly printed — never invent items, prices, or warranty periods
- Do NOT guess warranty duration from product category or consumer law — leave warrantyDurationMonths null unless stated on the document
- Compute warrantyExpiryDate ONLY when both purchaseDate and warrantyDurationMonths are clearly printed; otherwise null
- Mark confidence "low" if the image text is blurry, cropped, handwritten, or mostly unreadable
- Mark confidence "medium" if some important fields are missing or uncertain
- Mark confidence "high" only when product, retailer, and dates/duration are clearly readable
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: 'warranty_receipt_extraction',
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return WarrantyExtractionResult.fromJson(json);
    } catch (_) {
      return const WarrantyExtractionResult();
    }
  }

  Future<ReceiptExtractionResult> _extractReceiptDataViaClaude(
    String ocrText,
  ) async {
    final prompt = '''
You are a receipt data extraction expert for Qatar retail receipts.
Analyze this OCR-extracted text from a receipt photo.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "productName": "<main product purchased, else empty string>",
  "purchaseDate": "<ISO8601 date YYYY-MM-DD if found, else empty string>",
  "store": "<store/retailer name if found, else empty string>",
  "price": <number, the price paid for this item, or null>,
  "warrantyPeriodGuess": <integer months, your best estimate based
    on product category and Qatar consumer protection law minimums,
    or null if product type unclear>,
  "confidence": <number 0.0 to 1.0>
}

Rules:
- Qatar Consumer Protection Law mandates minimum 1-2 years on
  electronics and major appliances
- confidence below 0.5 means caller will leave fields blank
  for manual entry
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: 'receipt_extraction',
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return ReceiptExtractionResult.fromJson(json);
    } catch (_) {
      return const ReceiptExtractionResult(confidence: 0.0);
    }
  }

  Future<BookingConfirmationExtractionResult>
      _extractBookingConfirmationViaClaude(String ocrText) async {
    final prompt = '''
You are a travel booking confirmation extraction expert.
Analyze OCR text from a flight, hotel, or car rental confirmation.

OCR Text:
$ocrText

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "bookingType": "<flight|hotel|carRental or empty string if unclear>",
  "destinationCity": "<city if clearly stated, else empty string>",
  "destinationCountry": "<country if clearly stated, else empty string>",
  "startDateTime": "<ISO8601 datetime for check-in/departure if found, else empty>",
  "endDateTime": "<ISO8601 datetime for check-out/arrival/return if found, else empty>",
  "confirmationNumber": "<booking/confirmation/PNR reference if found, else empty>",
  "providerName": "<airline/hotel/rental company if found, else empty>",
  "guestName": "<passenger or guest name if found, else empty>",
  "confidence": <number 0.0 to 1.0>,
  "fieldConfidence": {
    "bookingType": <0.0-1.0>,
    "destinationCity": <0.0-1.0>,
    "startDateTime": <0.0-1.0>,
    "confirmationNumber": <0.0-1.0>
  }
}

Rules:
- Extract ONLY what is explicitly present — never invent missing fields
- Use empty strings for fields not clearly found in the text
- confidence below 0.5 means caller leaves uncertain fields blank
- Do not guess destinations or dates from context alone
''';

    final raw = await _claudeService.sendMessage(
      prompt,
      requestType: TripPlannerConfig.bookingImportRequestType,
    );
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return BookingConfirmationExtractionResult.fromJson(json);
    } catch (_) {
      return const BookingConfirmationExtractionResult(confidence: 0.0);
    }
  }
}

// ─── RIVERPOD PROVIDER ───────────────────────────────────

final documentExtractionServiceProvider =
    Provider<DocumentExtractionService>((ref) {
  final claudeService = ref.read(claudeAIServiceProvider);
  return DocumentExtractionService(claudeService);
});
