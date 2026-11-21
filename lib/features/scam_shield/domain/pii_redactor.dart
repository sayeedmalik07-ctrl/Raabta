/// Best-effort PII redaction for ScamShield off-device payloads only.
///
/// Local deterministic checks always use the original user text.
abstract final class PiiRedactor {
  static const phoneToken = '[PHONE]';
  static const accountToken = '[ACCOUNT]';
  static const cardToken = '[CARD]';
  static const idToken = '[ID]';
  static const emailToken = '[EMAIL]';
  static const codeToken = '[CODE]';

  static final _emailPattern = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
  );

  static final _ibanPattern = RegExp(
    r'\b[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}\b',
    caseSensitive: false,
  );

  static final _cardCandidate = RegExp(
    r'(?:\b|\d)([0-9٠-٩۰-۹][0-9٠-٩۰-۹\s\-]{11,22}[0-9٠-٩۰-۹])(?:\b|\D)',
  );

  static final _qidPattern = RegExp(
    r'\b[0-9٠-٩۰-۹]{11}\b',
  );

  static final _qatarPhonePattern = RegExp(
    r'(?:\+974[\s\-]?)?[3456789](?:[0-9٠-٩۰-۹\s\-]{6}[0-9٠-٩۰-۹])',
  );

  static final _intlPhonePattern = RegExp(
    r'\+[0-9٠-٩۰-۹][0-9٠-٩۰-۹\s\-()]{7,}[0-9٠-٩۰-۹]',
  );

  static final _longDigitPattern = RegExp(
    r'\b[0-9٠-٩۰-۹]{10,}\b',
  );

  static final _otpContextPattern = RegExp(
    r'(?:otp|one[\s-]?time|verification[\s-]?code|pin|password|passcode|رمز|كود|پاس|पास|कोड)',
    caseSensitive: false,
  );

  static final _arabicIndicDigitRun = RegExp(
    r'[٠-٩۰-۹]{8,}',
  );

  static final _embeddedUrlPattern = RegExp(
    r'https?://[^\s<>"]+',
    caseSensitive: false,
  );

  static RedactionResult redact(String input) {
    if (input.isEmpty) {
      return const RedactionResult(text: '', kinds: []);
    }

    final kinds = <String>{};
    var result = input;

    result = _redactEmbeddedUrls(result, kinds);
    result = _replaceAll(result, _emailPattern, emailToken, 'email', kinds);

    result = _redactCards(result, kinds);
    result = _replaceAll(
      result,
      _ibanPattern,
      accountToken,
      'account',
      kinds,
    );

    result = _replaceMapped(result, _qidPattern, (match) {
      kinds.add('id');
      return idToken;
    });

    result = _replaceMapped(result, _intlPhonePattern, (_) {
      kinds.add('phone');
      return phoneToken;
    });
    result = _replaceMapped(result, _qatarPhonePattern, (match) {
      final digits = _asciiDigitsOnly(match.group(0)!);
      final localDigits =
          digits.startsWith('974') ? digits.substring(3) : digits;
      if (localDigits.length != 8) return match.group(0)!;
      kinds.add('phone');
      return phoneToken;
    });
    result = _replaceMapped(result, _arabicIndicDigitRun, (_) {
      kinds.add('phone');
      return phoneToken;
    });

    result = _redactOtpLikeCodes(result, kinds);

    result = _replaceMapped(result, _longDigitPattern, (match) {
      final digits = _asciiDigitsOnly(match.group(0)!);
      if (digits.length == 11) {
        kinds.add('id');
        return idToken;
      }
      kinds.add('account');
      return accountToken;
    });

    return RedactionResult(
      text: result,
      kinds: kinds.toList()..sort(),
    );
  }

  /// Strips query parameters / fragments that may carry identifiers or tokens.
  static String sanitizeUriForWebRisk(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return value;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return value;

    final kept = <String, String>{};
    for (final entry in uri.queryParameters.entries) {
      if (_isSensitiveQueryParam(entry.key, entry.value)) continue;
      kept[entry.key] = entry.value;
    }

    var fragment = uri.fragment;
    if (fragment.isNotEmpty && _isSensitiveQueryValue(fragment)) {
      fragment = '';
    }

    final buffer = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.authority)
      ..write(uri.path.isEmpty ? '/' : uri.path);
    if (kept.isNotEmpty) {
      buffer
        ..write('?')
        ..write(Uri(queryParameters: kept).query);
    }
    if (fragment.isNotEmpty) {
      buffer
        ..write('#')
        ..write(fragment);
    }
    return buffer.toString();
  }

  static String _redactEmbeddedUrls(String input, Set<String> kinds) {
    return input.replaceAllMapped(_embeddedUrlPattern, (match) {
      final sanitized = sanitizeUriForWebRisk(match.group(0)!);
      if (sanitized != match.group(0)) {
        kinds.add('url');
      }
      return sanitized;
    });
  }

  static String _redactCards(String input, Set<String> kinds) {
    return input.replaceAllMapped(_cardCandidate, (match) {
      final digits = _asciiDigitsOnly(match.group(1)!);
      if (digits.length < 13 || digits.length > 19) return match.group(0)!;
      if (!_passesLuhn(digits)) return match.group(0)!;
      kinds.add('card');
      return match.group(0)!.replaceFirst(match.group(1)!, cardToken);
    });
  }

  static String _redactOtpLikeCodes(String input, Set<String> kinds) {
    final codePattern = RegExp(r'\b[0-9٠-٩۰-۹]{4,8}\b');
    return input.replaceAllMapped(codePattern, (match) {
      final raw = match.group(0)!;
      final digits = _asciiDigitsOnly(raw);
      final start = match.start;
      final contextStart = start - 48 < 0 ? 0 : start - 48;
      final context = input.substring(contextStart, start);
      if (!_otpContextPattern.hasMatch(context)) {
        final n = int.tryParse(digits);
        if (n != null && n <= 99999) return raw;
        return raw;
      }
      kinds.add('code');
      return codeToken;
    });
  }

  static String _replaceAll(
    String input,
    RegExp pattern,
    String token,
    String kind,
    Set<String> kinds,
  ) {
    if (!pattern.hasMatch(input)) return input;
    kinds.add(kind);
    return input.replaceAll(pattern, token);
  }

  static String _replaceMapped(
    String input,
    RegExp pattern,
    String Function(Match match) replace,
  ) {
    return input.replaceAllMapped(pattern, replace);
  }

  static bool _isSensitiveQueryParam(String name, String value) {
    final lower = name.toLowerCase();
    const names = {
      'token',
      'access_token',
      'auth',
      'session',
      'sessionid',
      'otp',
      'code',
      'pin',
      'password',
      'key',
      'api_key',
      'userid',
      'user_id',
      'email',
      'phone',
      'qid',
      'iban',
    };
    if (names.contains(lower)) return true;
    return _isSensitiveQueryValue(value);
  }

  static bool _isSensitiveQueryValue(String value) {
    if (value.isEmpty) return false;
    if (RegExp(r'[0-9٠-٩۰-۹]{4,}').hasMatch(value)) return true;
    if (RegExp(r'^[A-Za-z0-9_\-]{16,}$').hasMatch(value)) return true;
    if (_emailPattern.hasMatch(value)) return true;
    return false;
  }

  static String _asciiDigitsOnly(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.codeUnits) {
      final ch = String.fromCharCode(codeUnit);
      if (ch == '٠') {
        buffer.write('0');
      } else if (ch == '١') {
        buffer.write('1');
      } else if (ch == '٢') {
        buffer.write('2');
      } else if (ch == '٣') {
        buffer.write('3');
      } else if (ch == '٤') {
        buffer.write('4');
      } else if (ch == '٥') {
        buffer.write('5');
      } else if (ch == '٦') {
        buffer.write('6');
      } else if (ch == '٧') {
        buffer.write('7');
      } else if (ch == '٨') {
        buffer.write('8');
      } else if (ch == '٩') {
        buffer.write('9');
      } else if (ch == '۰') {
        buffer.write('0');
      } else if (ch == '۱') {
        buffer.write('1');
      } else if (ch == '۲') {
        buffer.write('2');
      } else if (ch == '۳') {
        buffer.write('3');
      } else if (ch == '۴') {
        buffer.write('4');
      } else if (ch == '۵') {
        buffer.write('5');
      } else if (ch == '۶') {
        buffer.write('6');
      } else if (ch == '۷') {
        buffer.write('7');
      } else if (ch == '۸') {
        buffer.write('8');
      } else if (ch == '۹') {
        buffer.write('9');
      } else if (codeUnit >= 0x30 && codeUnit <= 0x39) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  static bool _passesLuhn(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = digits.codeUnitAt(i) - 0x30;
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}

class RedactionResult {
  const RedactionResult({
    required this.text,
    required this.kinds,
  });

  final String text;
  final List<String> kinds;
}
