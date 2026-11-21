/// On-device IBAN validation — ISO 13616 mod-97-10.
abstract final class QatarIbanValidator {
  static const qatarCountryCode = 'QA';
  static const qatarIbanLength = 29;

  /// Bank codes bundled where Raabta could confirm participation labels from
  /// public bank branding (expand via editorial review — not a QCB API).
  static const knownBankCodes = <String, String>{
    'QNBA': 'QNB',
    'CBQA': 'Commercial Bank of Qatar',
    'DOHB': 'Doha Bank',
    'QISB': 'Qatar Islamic Bank',
    'ABQQ': 'Ahli Bank',
    'BRWA': 'Barwa Bank',
    'INIL': 'International Bank of Qatar',
  };

  static IbanValidationResult validate(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (normalized.isEmpty) {
      return const IbanValidationResult(kind: IbanValidationKind.empty);
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(normalized)) {
      return const IbanValidationResult(kind: IbanValidationKind.invalidFormat);
    }

    if (normalized.length < 15) {
      return const IbanValidationResult(kind: IbanValidationKind.invalidFormat);
    }

    if (!isValidMod97(normalized)) {
      return const IbanValidationResult(kind: IbanValidationKind.checksumFailed);
    }

    if (normalized.startsWith(qatarCountryCode)) {
      if (normalized.length != qatarIbanLength) {
        return const IbanValidationResult(
          kind: IbanValidationKind.invalidQatarLength,
        );
      }
      final bankCode = normalized.substring(4, 8);
      final bankName = knownBankCodes[bankCode];
      return IbanValidationResult(
        kind: bankName != null
            ? IbanValidationKind.qatarKnownBank
            : IbanValidationKind.qatarUnknownBankCode,
        bankCode: bankCode,
        bankName: bankName,
      );
    }

    return const IbanValidationResult(kind: IbanValidationKind.foreign);
  }

  static bool isValidMod97(String iban) {
    final rearranged = iban.substring(4) + iban.substring(0, 4);
    final numeric = StringBuffer();
    for (final ch in rearranged.split('')) {
      if (RegExp(r'[0-9]').hasMatch(ch)) {
        numeric.write(ch);
      } else {
        numeric.write(ch.codeUnitAt(0) - 55);
      }
    }
    var remainder = 0;
    final s = numeric.toString();
    for (var i = 0; i < s.length; i++) {
      remainder = (remainder * 10 + int.parse(s[i])) % 97;
    }
    return remainder == 1;
  }

  /// For unit tests — build a valid QA IBAN with computed check digits.
  static String syntheticQatarIban({
    required String bankCode,
    required String accountBody,
  }) {
    final body = accountBody
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .toUpperCase()
        .padRight(21, '0')
        .substring(0, 21);
    final partial = '${qatarCountryCode}00$bankCode$body';
    for (var check = 0; check <= 99; check++) {
      final candidate = partial.replaceRange(2, 4, check.toString().padLeft(2, '0'));
      if (isValidMod97(candidate)) return candidate;
    }
    throw StateError('Could not compute check digits');
  }
}

enum IbanValidationKind {
  empty,
  invalidFormat,
  checksumFailed,
  invalidQatarLength,
  qatarKnownBank,
  qatarUnknownBankCode,
  foreign,
}

class IbanValidationResult {
  const IbanValidationResult({
    required this.kind,
    this.bankCode,
    this.bankName,
  });

  final IbanValidationKind kind;
  final String? bankCode;
  final String? bankName;

  bool get isQatar => kind == IbanValidationKind.qatarKnownBank ||
      kind == IbanValidationKind.qatarUnknownBankCode;
}
