abstract final class NumberNormalizer {
  static String toAsciiDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(rune - 0x0660 + 0x30);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(rune - 0x06F0 + 0x30);
      } else {
        buffer.write(String.fromCharCode(rune));
      }
    }
    return buffer.toString();
  }

  static String stripToDialChars(String input) {
    final ascii = toAsciiDigits(input);
    return ascii.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
