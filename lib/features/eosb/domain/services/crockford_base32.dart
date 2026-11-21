/// Crockford Base32 encoding (exact alphabet — not RFC 4648).
///
/// Alphabet: `0123456789ABCDEFGHJKMNPQRSTVWXYZ` (32 symbols).
/// Excludes I, L, O, U to avoid visual ambiguity.
///
/// - Padding: none
/// - Case: uppercase output; decoding accepts lowercase
/// - URL safety: alphanumeric only
/// - Length: 16 bytes (128 bits) → 26 characters
/// - Decoding: maps i/l → 1, o → 0, u → V per Crockford spec
abstract final class CrockfordBase32 {
  static const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static const _decodeMap = <int, int>{
    48: 0,
    49: 1,
    50: 2,
    51: 3,
    52: 4,
    53: 5,
    54: 6,
    55: 7,
    56: 8,
    57: 9,
    65: 10,
    66: 11,
    67: 12,
    68: 13,
    69: 14,
    70: 15,
    71: 16,
    72: 17,
    74: 18,
    75: 19,
    77: 20,
    78: 21,
    80: 22,
    81: 23,
    82: 24,
    83: 25,
    84: 26,
    86: 27,
    87: 28,
    88: 29,
    89: 30,
    90: 31,
    // lowercase
    97: 10,
    98: 11,
    99: 12,
    100: 13,
    101: 14,
    102: 15,
    103: 16,
    104: 17,
    106: 18,
    107: 19,
    109: 20,
    110: 21,
    112: 22,
    113: 23,
    114: 24,
    115: 25,
    116: 26,
    118: 27,
    119: 28,
    120: 29,
    121: 30,
    122: 31,
    // Crockford ambiguous mappings
    73: 1,
    105: 1,
    76: 1,
    108: 1,
    79: 0,
    111: 0,
    85: 27,
    117: 27,
  };

  /// Encodes [bytes] to uppercase Crockford Base32 without padding.
  static String encode(List<int> bytes) {
    if (bytes.isEmpty) return '';

    final buffer = StringBuffer();
    var bufferBits = 0;
    var bufferValue = 0;

    for (final byte in bytes) {
      bufferValue = (bufferValue << 8) | (byte & 0xff);
      bufferBits += 8;

      while (bufferBits >= 5) {
        bufferBits -= 5;
        final index = (bufferValue >> bufferBits) & 0x1f;
        buffer.write(alphabet[index]);
      }
    }

    if (bufferBits > 0) {
      final index = (bufferValue << (5 - bufferBits)) & 0x1f;
      buffer.write(alphabet[index]);
    }

    return buffer.toString();
  }

  /// Decodes Crockford Base32 [input] to bytes. Throws on invalid characters.
  static List<int> decode(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return const [];

    var bufferBits = 0;
    var bufferValue = 0;
    final out = <int>[];

    for (final codeUnit in normalized.codeUnits) {
      final value = _decodeMap[codeUnit];
      if (value == null) {
        throw FormatException('Invalid Crockford Base32 character: $codeUnit');
      }
      bufferValue = (bufferValue << 5) | value;
      bufferBits += 5;
      if (bufferBits >= 8) {
        bufferBits -= 8;
        out.add((bufferValue >> bufferBits) & 0xff);
      }
    }

    return out;
  }
}
