/// Pure candidate extraction from pasted/scanned text — no persistence.
abstract final class PaymentCandidateExtractor {
  static final _ibanRegex = RegExp(
    r'\bQA[\s]?[0-9]{2}[\s]?(?:[A-Z0-9]{4}[\s]?){1,7}[A-Z0-9]{1,4}\b',
    caseSensitive: false,
  );

  static final _ibanCompact = RegExp(r'\bQA[0-9A-Z]{25,29}\b', caseSensitive: false);

  static final _phoneRegex = RegExp(
    r'(?:\+974|974)[\s\-]?[34567][0-9]{7}\b|(?<!\d)[34567][0-9]{7}\b',
  );

  static final _urlRegex = RegExp(
    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static PaymentExtractedCandidates extract(String text) {
    if (text.trim().isEmpty) {
      return const PaymentExtractedCandidates();
    }

    final ibans = <String>{};
    for (final m in _ibanRegex.allMatches(text)) {
      ibans.add(_normalizeIban(m.group(0)!));
    }
    for (final m in _ibanCompact.allMatches(text)) {
      ibans.add(_normalizeIban(m.group(0)!));
    }

    final phones = _phoneRegex
        .allMatches(text)
        .map((m) => m.group(0)!.replaceAll(RegExp(r'[\s\-]'), ''))
        .toSet();

    final links = _urlRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .map((u) => u.endsWith('.') ? u.substring(0, u.length - 1) : u)
        .toSet();

    return PaymentExtractedCandidates(
      ibans: ibans.toList(growable: false),
      phones: phones.toList(growable: false),
      links: links.toList(growable: false),
    );
  }

  static String _normalizeIban(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
}

class PaymentExtractedCandidates {
  const PaymentExtractedCandidates({
    this.ibans = const [],
    this.phones = const [],
    this.links = const [],
  });

  final List<String> ibans;
  final List<String> phones;
  final List<String> links;

  bool get isEmpty => ibans.isEmpty && phones.isEmpty && links.isEmpty;
}
