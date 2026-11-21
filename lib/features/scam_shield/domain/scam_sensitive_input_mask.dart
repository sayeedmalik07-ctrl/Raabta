/// Masks sensitive patterns before display or local preview storage.
abstract final class ScamSensitiveInputMask {
  static final _cardPattern = RegExp(
    r'\b(?:\d[ -]*?){13,19}\b',
  );

  static String mask(String input) {
    var masked = input;
    masked = masked.replaceAllMapped(_cardPattern, (match) {
      final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 13) return match.group(0)!;
      final last4 = digits.substring(digits.length - 4);
      return '•••• •••• •••• $last4';
    });

    masked = _maskOtpLikeSequences(masked);
    return masked;
  }

  static String _maskOtpLikeSequences(String text) {
    final otpPattern = RegExp(r'\b(\d{4,8})\b');
    return text.replaceAllMapped(otpPattern, (match) {
      final value = match.group(1)!;
      if (value.length >= 6) return '••••••';
      return match.group(0)!;
    });
  }

  static bool containsSensitiveCredential(String text) {
    final lower = text.toLowerCase();
    const markers = ['otp', 'cvv', 'pin', 'password', 'card number'];
    return markers.any(lower.contains) || _cardPattern.hasMatch(text);
  }
}
