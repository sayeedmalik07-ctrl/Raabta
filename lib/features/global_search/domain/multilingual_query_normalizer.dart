import 'package:raabta/features/global_search/domain/multilingual_search_terminology.dart';

/// Result of deterministic multilingual normalization (S7).
class MultilingualNormalizationResult {
  const MultilingualNormalizationResult({
    required this.originalQuery,
    required this.normalizedText,
    required this.canonicalLower,
    required this.detectedLanguage,
  });

  final String originalQuery;
  final String normalizedText;
  final String canonicalLower;
  final String detectedLanguage;
}

/// Local deterministic multilingual normalization for Global Search (S7).
abstract final class MultilingualQueryNormalizer {
  static MultilingualNormalizationResult normalize(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const MultilingualNormalizationResult(
        originalQuery: '',
        normalizedText: '',
        canonicalLower: '',
        detectedLanguage: 'english',
      );
    }

    var working = _normalizeUnicode(trimmed);
    working = _normalizeDigits(working);
    working = _applyPhraseReplacements(working);
    working = _normalizeArabicCharacters(working);
    working = _applyPhraseReplacements(working);
    working = _reorderPriceComparators(working);
    working = _collapseWhitespace(working);

    final detected = _detectLanguage(trimmed, working);
    final lower = _latinLowercase(working);

    return MultilingualNormalizationResult(
      originalQuery: trimmed,
      normalizedText: working,
      canonicalLower: lower,
      detectedLanguage: detected,
    );
  }

  static String _latinLowercase(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0041 && rune <= 0x005A) {
        buffer.writeCharCode(rune + 32);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String _normalizeUnicode(String input) {
    return input.replaceAll('\u200f', '').replaceAll('\u200e', '').trim();
  }

  static String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      buffer.writeCharCode(_asciiDigit(rune) ?? rune);
    }
    return buffer.toString();
  }

  static int? _asciiDigit(int rune) {
    if (rune >= 0x0660 && rune <= 0x0669) return 0x30 + (rune - 0x0660);
    if (rune >= 0x06F0 && rune <= 0x06F9) return 0x30 + (rune - 0x06F0);
    return null;
  }

  static String _normalizeArabicCharacters(String input) {
    return input
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ـ', '');
  }

  static String _applyPhraseReplacements(String input) {
    var working = input;

    for (final entry in MultilingualSearchTerminology.orderedReplacements) {
      final phrase = entry.key;
      final canonical = entry.value;
      if (phrase.isEmpty) continue;
      if (_containsPhrase(working, phrase)) {
        working = _replacePhrase(working, phrase, canonical);
      }
    }

    return working;
  }

  static bool _containsPhrase(String haystack, String needle) {
    if (_isMostlyLatin(needle)) {
      return haystack.toLowerCase().contains(needle.toLowerCase());
    }
    return haystack.contains(needle);
  }

  static bool _isMostlyLatin(String value) {
    var latin = 0;
    var other = 0;
    for (final rune in value.runes) {
      if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        latin++;
      } else if (!_isWhitespaceRune(rune)) {
        other++;
      }
    }
    return latin > 0 && latin >= other;
  }

  static bool _isWhitespaceRune(int rune) {
    return rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D;
  }

  static String _replacePhrase(
    String input,
    String phrase,
    String replacement,
  ) {
    if (_isMostlyLatin(phrase)) {
      return _replaceLatinPhraseInsensitive(input, phrase, replacement);
    }

    var working = input;
    while (true) {
      final matchIndex = working.indexOf(phrase);
      if (matchIndex == -1) break;
      final before = working.substring(0, matchIndex).trimRight();
      final after = working.substring(matchIndex + phrase.length).trimLeft();
      working = [
        before,
        if (replacement.isNotEmpty) replacement,
        after,
      ].where((part) => part.isNotEmpty).join(' ');
    }
    return working;
  }

  static String _replaceLatinPhraseInsensitive(
    String input,
    String phrase,
    String replacement,
  ) {
    final lowerInput = input.toLowerCase();
    final lowerPhrase = phrase.toLowerCase();
    final buffer = StringBuffer();
    var index = 0;

    while (index < input.length) {
      final matchIndex = lowerInput.indexOf(lowerPhrase, index);
      if (matchIndex == -1) {
        buffer.write(input.substring(index));
        break;
      }
      buffer.write(input.substring(index, matchIndex));
      if (replacement.isNotEmpty) {
        if (buffer.isNotEmpty && !buffer.toString().endsWith(' ')) {
          buffer.write(' ');
        }
        buffer.write(replacement);
        if (matchIndex + phrase.length < input.length) {
          buffer.write(' ');
        }
      }
      index = matchIndex + phrase.length;
    }

    return _collapseWhitespace(buffer.toString());
  }

  static String _reorderPriceComparators(String input) {
    var working = input;
    working = working.replaceAllMapped(
      RegExp(r'(\d[\d,]*)\s+qar\s+under', caseSensitive: false),
      (m) => 'under ${m.group(1)!} qar',
    );
    working = working.replaceAllMapped(
      RegExp(r'(\d[\d,]*)\s+qar\s+above', caseSensitive: false),
      (m) => 'above ${m.group(1)!} qar',
    );
    working = working.replaceAllMapped(
      RegExp(r'(\d[\d,]*)\s+above', caseSensitive: false),
      (m) => 'above ${m.group(1)!}',
    );
    working = working.replaceAllMapped(
      RegExp(r'(\d[\d,]*)\s+under', caseSensitive: false),
      (m) => 'under ${m.group(1)!}',
    );
    return working;
  }

  static String _collapseWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _detectLanguage(String original, String normalized) {
    var arabic = 0;
    var devanagari = 0;
    var latin = 0;

    for (final rune in original.runes) {
      if (_isArabicScript(rune)) {
        arabic++;
      } else if (rune >= 0x0900 && rune <= 0x097F) {
        devanagari++;
      } else if ((rune >= 0x0041 && rune <= 0x007A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        latin++;
      }
    }

    final lower = normalized.toLowerCase();
    final hinglishHits = [
      'mujhe',
      'chahiye',
      'paas',
      'nazdeek',
      'mein',
      'ki job',
      'bijli',
      'mistri',
      'wala',
    ].where(lower.contains).length;

    if (devanagari > arabic && devanagari > 0) return 'hindi';
    if (arabic > 0 && latin > 0 && hinglishHits > 0) return 'hinglish';
    if (arabic > 0) {
      if (_looksUrdu(original)) return 'urdu';
      return 'arabic';
    }
    if (hinglishHits >= 2) return 'hinglish';
    if (latin > 0) return 'english';
    return 'mixed';
  }

  static bool _isArabicScript(int rune) {
    return (rune >= 0x0600 && rune <= 0x06FF) ||
        (rune >= 0x0750 && rune <= 0x077F) ||
        (rune >= 0xFB50 && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF);
  }

  static bool _looksUrdu(String input) {
    const urduMarkers = ['ہ', 'ے', 'ں', 'ڈ', 'ڑ', 'ژ', 'گ', 'چ', 'پ', 'ک'];
    return urduMarkers.any(input.contains);
  }

  /// Detects near-me intent from normalized multilingual text.
  static bool containsNearMe(String canonicalLower) {
    return canonicalLower.contains('near me') ||
        canonicalLower.contains('nearby');
  }
}
