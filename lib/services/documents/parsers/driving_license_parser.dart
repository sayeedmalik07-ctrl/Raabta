import 'package:raabta/services/documents/utils/date_parse_utils.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// Label-anchored Qatar driving license extractor.
class DrivingLicenseParser {
  DrivingLicenseParser._();

  static const _licenseLabels = [
    'License No',
    'Licence No',
    'License Number',
    'Licence Number',
    'DL No',
    'رقم الرخصة',
    'رخصة القيادة',
  ];

  static const _nameLabels = [
    'Name',
    'Holder',
    'الاسم',
  ];

  static const _expiryLabels = [
    'Expiry Date',
    'Expiry',
    'Valid Until',
    'تاريخ الانتهاء',
  ];

  static const _categoryLabels = [
    'Class',
    'Category',
    'Categories',
    'الفئة',
  ];

  static final _licenseNumberPattern = RegExp(
    r'\b(\d{6,12})\b',
  );

  static DrivingLicenseParseResult? parse(String ocrText) {
    if (!_looksLikeDrivingLicense(ocrText)) return null;

    final licenseNumber = _extractLicenseNumber(ocrText);
    final name = OcrTextUtils.valueAfterLabel(
      ocrText,
      _nameLabels,
      valuePattern: RegExp(r"^[A-Za-z\u0600-\u06FF\s\-'.]+$"),
    );
    final expiry = DateParseUtils.parseNearLabels(ocrText, _expiryLabels);
    final categories = OcrTextUtils.valueAfterLabel(ocrText, _categoryLabels);

    var confidence = 0.0;
    if (licenseNumber != null) confidence += 0.45;
    if (name != null && name.length >= 3) confidence += 0.2;
    if (expiry != null) confidence += 0.2;
    if (categories != null && categories.isNotEmpty) confidence += 0.1;
    if (OcrTextUtils.containsAny(ocrText, [
      'Driving License',
      'Traffic Department',
      'Ministry of Interior',
      'رخصة قيادة',
    ])) {
      confidence += 0.1;
    }

    if (licenseNumber == null) return null;

    return DrivingLicenseParseResult(
      licenseNumber: licenseNumber,
      holderName: name?.trim(),
      expiryDate: expiry,
      categories: categories?.trim(),
      confidence: confidence.clamp(0.0, 0.92),
    );
  }

  static bool _looksLikeDrivingLicense(String text) {
    return OcrTextUtils.containsAny(text, [
      'Driving License',
      'Driving Licence',
      'Traffic Department',
      'Ministry of Interior',
      'رخصة قيادة',
      'رخصة القيادة',
      ..._licenseLabels,
    ]);
  }

  static String? _extractLicenseNumber(String text) {
    final labeled = OcrTextUtils.valueAfterLabel(
      text,
      _licenseLabels,
      valuePattern: RegExp(r'^[\d\s\-/]+$'),
    );
    if (labeled != null) {
      final digits = labeled.replaceAll(RegExp(r'[\s\-/]'), '');
      if (digits.length >= 6 && digits.length <= 12) return digits;
    }

    for (final match in _licenseNumberPattern.allMatches(text)) {
      final value = match.group(1)!;
      if (value.length >= 6 && value.length <= 12) return value;
    }
    return null;
  }
}

class DrivingLicenseParseResult {
  const DrivingLicenseParseResult({
    this.licenseNumber,
    this.holderName,
    this.expiryDate,
    this.categories,
    required this.confidence,
  });

  final String? licenseNumber;
  final String? holderName;
  final DateTime? expiryDate;
  final String? categories;
  final double confidence;
}
