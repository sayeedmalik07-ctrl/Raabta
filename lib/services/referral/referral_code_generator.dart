import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Stable, non-sequential referral codes derived from Firebase UID.
abstract final class ReferralCodeGenerator {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String fromUid(String uid) {
    final digest = sha256.convert(utf8.encode('raabta:referral:v1:$uid'));
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(_alphabet[digest.bytes[i] % _alphabet.length]);
    }
    return buffer.toString();
  }
}
