/// Dart mirror of Android call-screening heuristics — for unit tests only.
abstract final class ScamCallScreeningLogic {
  static bool looksLikeSpoofedLocal(String number) {
    final normalized = number.replaceAll(RegExp(r'[^\d+]'), '');
    final digits = normalized.replaceFirst('+974', '').replaceFirst('974', '');
    if (digits.length != 8) return false;
    return digits == '12345678' ||
        digits == '00000000' ||
        digits.split('').every((c) => c == digits[0]);
  }

  static bool isLikelyBenignQatarNumber(String number) {
    final normalized = number.replaceAll(RegExp(r'[^\d+]'), '');
    final digits = normalized.replaceFirst('+974', '').replaceFirst('974', '');
    if (digits.length != 8) return false;
    final first = digits[0];
    return '34567'.contains(first);
  }

  static bool shouldFlagCall({
    required String number,
    String? stirShakenStatus,
  }) {
    final reasons = <String>[];
    if (stirShakenStatus == 'failed') {
      reasons.add('stir_shaken_failed');
    }
    if (looksLikeSpoofedLocal(number)) {
      reasons.add('suspicious_local_pattern');
    }
    if (reasons.length == 1 &&
        reasons.first == 'suspicious_local_pattern' &&
        isLikelyBenignQatarNumber(number)) {
      return false;
    }
    return reasons.isNotEmpty;
  }
}
