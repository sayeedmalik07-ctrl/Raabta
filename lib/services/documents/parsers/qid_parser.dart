import 'package:raabta/services/documents/utils/date_parse_utils.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// Label-anchored Qatar ID (QID) extractor.
///
/// QID numbers are 11 digits; first digit is commonly 2 (1900s birth cohort)
/// or 3 (2000s birth cohort). Last digit is a weighted check digit (mod 10).
/// Card layouts vary slightly by version — this parser anchors on bilingual labels.
class QidParser {
  QidParser._();

  static const _qidLabels = [
    'ID No',
    'ID Number',
    'ID NO',
    'QID',
    'Qatar ID',
    'Personal No',
    'رقم الهوية',
    'الرقم الشخصي',
    'بطاقة شخصية',
  ];

  static const _nameLabels = [
    'Name',
    'Full Name',
    'Holder Name',
    'الاسم',
    'الاسم الكامل',
  ];

  static const _expiryLabels = [
    'Expiry Date',
    'Expiry',
    'Valid Until',
    'Date of Expiry',
    'تاريخ الانتهاء',
    'تاريخ نهاية الصلاحية',
  ];

  static const _nationalityLabels = [
    'Nationality',
    'Country',
    'الجنسية',
  ];

  static final _qidPattern = RegExp(r'\b([23]\d[\d\s]{9,10})\b');

  static QidParseResult? parse(String ocrText) {
    if (!_looksLikeQidCard(ocrText)) return null;

    final qidNumber = _extractQidNumber(ocrText);
    if (qidNumber == null) return null;

    final checkValid = validateQidCheckDigit(qidNumber);
    final name = OcrTextUtils.valueAfterLabel(
      ocrText,
      _nameLabels,
      valuePattern: RegExp(r"^[A-Za-z\u0600-\u06FF\s\-'.]+$"),
    );
    final expiry = DateParseUtils.parseNearLabels(ocrText, _expiryLabels) ??
        DateParseUtils.parseFirst(ocrText);
    final nationality = OcrTextUtils.valueAfterLabel(ocrText, _nationalityLabels);

    var confidence = 0.0;
    if (checkValid) confidence += 0.55;
    if (name != null && name.length >= 3) confidence += 0.15;
    if (expiry != null) confidence += 0.15;
    if (nationality != null && nationality.isNotEmpty) confidence += 0.05;
    if (OcrTextUtils.containsAny(ocrText, ['State of Qatar', 'دولة قطر', 'QID'])) {
      confidence += 0.1;
    }

    if (!checkValid) {
      confidence = confidence.clamp(0.0, 0.45);
    }

    return QidParseResult(
      qidNumber: qidNumber,
      holderName: name?.trim(),
      expiryDate: expiry,
      nationality: nationality?.trim(),
      checkDigitValid: checkValid,
      confidence: confidence.clamp(0.0, 0.95),
    );
  }

  static bool validateQidCheckDigit(String qid) {
    if (!RegExp(r'^[23]\d{10}$').hasMatch(qid)) return false;
    const weights = [2, 1, 2, 1, 2, 1, 2, 1, 2, 1];
    var total = 0;
    for (var i = 0; i < 10; i++) {
      final product = int.parse(qid[i]) * weights[i];
      total += product ~/ 10 + product % 10;
    }
    final check = (10 - (total % 10)) % 10;
    return check == int.parse(qid[10]);
  }

  static bool _looksLikeQidCard(String text) {
    return OcrTextUtils.containsAny(text, [
      'Qatar ID',
      'Residency Permit',
      'State of Qatar',
      'دولة قطر',
      'بطاقة',
      'QID',
      ..._qidLabels,
    ]) ||
        _extractQidNumber(text) != null;
  }

  static String? _extractQidNumber(String text) {
    final labeled = OcrTextUtils.valueAfterLabel(
      text,
      _qidLabels,
      valuePattern: RegExp(r'^[\d\s]+$'),
    );
    if (labeled != null) {
      final digits = labeled.replaceAll(RegExp(r'\s'), '');
      if (validateQidCheckDigit(digits)) return digits;
      if (RegExp(r'^[23]\d{10}$').hasMatch(digits)) return digits;
    }

    for (final match in _qidPattern.allMatches(text)) {
      final digits = match.group(1)!.replaceAll(RegExp(r'\s'), '');
      if (digits.length == 11) {
        if (validateQidCheckDigit(digits)) return digits;
      }
    }
    return null;
  }
}

class QidParseResult {
  const QidParseResult({
    this.qidNumber,
    this.holderName,
    this.expiryDate,
    this.nationality,
    required this.checkDigitValid,
    required this.confidence,
  });

  final String? qidNumber;
  final String? holderName;
  final DateTime? expiryDate;
  final String? nationality;
  final bool checkDigitValid;
  final double confidence;
}
