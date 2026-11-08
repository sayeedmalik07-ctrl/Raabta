/// Qatar numbering — simplified CRA-aligned rules (mobile 8 digits, leading 3–7).
///
/// **Audit gap:** full CRA numbering plan PDF was not fetched in-repo; landline
/// ranges use a conservative subset. Unknown patterns → [QatarPhoneValidationKind.unknown].
abstract final class QatarPhoneValidator {
  static QatarPhoneValidationResult validate(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) {
      return const QatarPhoneValidationResult(kind: QatarPhoneValidationKind.empty);
    }

    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.startsWith('00')) digits = digits.substring(2);

    if (digits.startsWith('974')) {
      digits = digits.substring(3);
    } else if (digits.length > 8 && !digits.startsWith('974')) {
      return const QatarPhoneValidationResult(
        kind: QatarPhoneValidationKind.foreign,
      );
    }

    if (digits.length != 8) {
      return const QatarPhoneValidationResult(
        kind: QatarPhoneValidationKind.invalidLength,
      );
    }

    final first = digits[0];
    if ('34567'.contains(first)) {
      return QatarPhoneValidationResult(
        kind: QatarPhoneValidationKind.qatarMobile,
        nationalNumber: digits,
      );
    }

    return QatarPhoneValidationResult(
      kind: QatarPhoneValidationKind.unknown,
      nationalNumber: digits,
    );
  }
}

enum QatarPhoneValidationKind {
  empty,
  foreign,
  invalidLength,
  qatarMobile,
  qatarLandline,
  unknown,
}

class QatarPhoneValidationResult {
  const QatarPhoneValidationResult({
    required this.kind,
    this.nationalNumber,
  });

  final QatarPhoneValidationKind kind;
  final String? nationalNumber;
}
