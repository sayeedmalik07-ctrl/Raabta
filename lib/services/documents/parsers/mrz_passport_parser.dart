import 'package:raabta/services/documents/utils/date_parse_utils.dart';

/// ICAO Doc 9303 TD3 passport MRZ parser with weighted 7-3-1 check digits.
class MrzPassportParser {
  MrzPassportParser._();

  static const int _lineLength = 44;

  static MrzPassportParseResult? parse(String ocrText) {
    final candidates = _findMrzLinePairs(ocrText);
    for (final pair in candidates) {
      final result = _parsePair(pair.line1, pair.line2);
      if (result != null) return result;
    }
    return null;
  }

  static MrzPassportParseResult? _parsePair(String rawLine1, String rawLine2) {
    var line1 = _normalizeMrzLine(rawLine1);
    var line2 = _normalizeMrzLine(rawLine2);

    line1 = _padOrTrim(line1, _lineLength);
    line2 = _padOrTrim(line2, _lineLength);

    if (!line1.startsWith('P')) return null;
    if (!_isMrzCharset(line1) || !_isMrzCharset(line2)) return null;

    final passportNumberField = line2.substring(0, 9);
    final passportCheck = line2[9];
    final nationality = line2.substring(10, 13);
    final dobField = line2.substring(13, 19);
    final dobCheck = line2[19];
    final sex = line2[20];
    final expiryField = line2.substring(21, 27);
    final expiryCheck = line2[27];
    final compositeField = line2.substring(0, 10) +
        line2.substring(13, 20) +
        line2.substring(21, 42);
    final compositeCheck = line2[42];

    final checks = <bool>[
      _verifyCheckDigit(passportNumberField, passportCheck),
      _verifyCheckDigit(dobField.substring(0, 6), dobCheck),
      _verifyCheckDigit(expiryField.substring(0, 6), expiryCheck),
      _verifyCheckDigit(compositeField, compositeCheck),
    ];

    final coreChecksValid = checks[0] && checks[1] && checks[2];
    final allChecksValid = coreChecksValid && checks[3];

    if (!coreChecksValid) {
      return MrzPassportParseResult(
        passportNumber: passportNumberField.replaceAll('<', '').trim(),
        nationality: nationality,
        holderName: _parseName(line1),
        dateOfBirth: _safeMrzDate(dobField.substring(0, 6), isExpiry: false),
        expiryDate: _safeMrzDate(expiryField.substring(0, 6), isExpiry: true),
        sex: sex == '<' ? null : sex,
        checkDigitsValid: false,
        confidence: 0.35,
      );
    }

    final passportNumber = passportNumberField.replaceAll('<', '').trim();
    final dob =
        DateParseUtils.parseMrzDate(dobField.substring(0, 6), isExpiry: false);
    final expiry = DateParseUtils.parseMrzDate(
      expiryField.substring(0, 6),
      isExpiry: true,
    );

    if (!DateParseUtils.isExpiryAfterIssue(expiry, dob)) {
      return null;
    }

    return MrzPassportParseResult(
      passportNumber: passportNumber.isEmpty ? null : passportNumber,
      nationality: nationality,
      holderName: _parseName(line1),
      dateOfBirth: dob,
      expiryDate: expiry,
      sex: sex == '<' ? null : sex,
      checkDigitsValid: allChecksValid,
      confidence: allChecksValid ? 0.98 : 0.92,
    );
  }

  static DateTime? _safeMrzDate(String yymmdd, {required bool isExpiry}) {
    if (!RegExp(r'^\d{6}$').hasMatch(yymmdd)) return null;
    try {
      return DateParseUtils.parseMrzDate(yymmdd, isExpiry: isExpiry);
    } catch (_) {
      return null;
    }
  }

  static String _parseName(String line1) {
    if (line1.length <= 5) return '';
    final nameField = line1.substring(5);
    final parts = nameField.split('<<').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final surname = parts.first.replaceAll('<', ' ').trim();
    final given = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll('<', ' ').trim()
        : '';
    if (given.isEmpty) return _titleCase(surname);
    return _titleCase('$given $surname');
  }

  static String _titleCase(String input) {
    return input
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static bool _verifyCheckDigit(String data, String checkChar) {
    if (!RegExp(r'^\d$').hasMatch(checkChar)) return false;
    return _checkDigit(data) == int.parse(checkChar);
  }

  static int _checkDigit(String data) {
    const weights = [7, 3, 1];
    var sum = 0;
    for (var i = 0; i < data.length; i++) {
      sum += _charValue(data[i]) * weights[i % 3];
    }
    return sum % 10;
  }

  static int _charValue(String char) {
    if (char == '<') return 0;
    final code = char.codeUnitAt(0);
    if (code >= 48 && code <= 57) return code - 48;
    if (code >= 65 && code <= 90) return code - 55;
    return 0;
  }

  static String _normalizeMrzLine(String line) {
    return line
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('«', '<')
        .replaceAll('‹', '<')
        .replaceAll(RegExp(r'[^A-Z0-9<]'), '');
  }

  static String _padOrTrim(String line, int length) {
    if (line.length >= length) return line.substring(0, length);
    return line.padRight(length, '<');
  }

  static bool _isMrzCharset(String line) =>
      RegExp(r'^[A-Z0-9<]+$').hasMatch(line);

  static List<_MrzPair> _findMrzLinePairs(String text) {
    final pairs = <_MrzPair>[];
    final lines = text
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (var i = 0; i < lines.length - 1; i++) {
      final l1 = _normalizeMrzLine(lines[i]);
      final l2 = _normalizeMrzLine(lines[i + 1]);
      if (l1.startsWith('P') &&
          l1.length >= 30 &&
          l2.length >= 30 &&
          _isMrzCharset(l1) &&
          _isMrzCharset(l2)) {
        pairs.add(_MrzPair(l1, l2));
      }
    }

    // Sliding window for OCR that merges MRZ into one block.
    final compact = text.toUpperCase().replaceAll(RegExp(r'[\s\n\r]'), '');
    for (var i = 0; i + (_lineLength * 2) <= compact.length; i++) {
      final l1 = compact.substring(i, i + _lineLength);
      final l2 = compact.substring(i + _lineLength, i + _lineLength * 2);
      if (l1.startsWith('P') && _isMrzCharset(l1) && _isMrzCharset(l2)) {
        pairs.add(_MrzPair(l1, l2));
      }
    }

    return pairs;
  }
}

class _MrzPair {
  const _MrzPair(this.line1, this.line2);
  final String line1;
  final String line2;
}

class MrzPassportParseResult {
  const MrzPassportParseResult({
    this.passportNumber,
    this.nationality,
    this.holderName,
    this.dateOfBirth,
    this.expiryDate,
    this.sex,
    required this.checkDigitsValid,
    required this.confidence,
  });

  final String? passportNumber;
  final String? nationality;
  final String? holderName;
  final DateTime? dateOfBirth;
  final DateTime? expiryDate;
  final String? sex;
  final bool checkDigitsValid;
  final double confidence;
}
