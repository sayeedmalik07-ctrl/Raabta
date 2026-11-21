import 'package:meta/meta.dart';

class OutdatedBrandEntry {
  const OutdatedBrandEntry({
    required this.name,
    required this.replacement,
    required this.since,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.verified,
    this.matchAliases = const [],
  });

  final String name;
  final String replacement;
  final String since;
  final String sourceLabel;
  final String sourceUrl;
  final bool verified;
  final List<String> matchAliases;

  factory OutdatedBrandEntry.fromJson(Map<String, dynamic> json) {
    return OutdatedBrandEntry(
      name: json['name'] as String? ?? '',
      replacement: json['replacement'] as String? ?? '',
      since: json['since'] as String? ?? '',
      sourceLabel: json['sourceLabel'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      verified: json['verified'] == true,
      matchAliases: (json['matchAliases'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

abstract final class OutdatedBrandCatalog {
  static List<OutdatedBrandEntry> _entries = _defaultSeed;

  static List<OutdatedBrandEntry> get entries => _entries;

  static List<OutdatedBrandEntry> get verifiedEntries =>
      _entries.where((e) => e.verified).toList(growable: false);

  @visibleForTesting
  static void installForTest(List<OutdatedBrandEntry> entries) {
    _entries = entries;
  }

  @visibleForTesting
  static void resetForTest() {
    _entries = _defaultSeed;
  }

  static void applyEntries(List<OutdatedBrandEntry> entries) {
    if (entries.isNotEmpty) _entries = entries;
  }

  static List<OutdatedBrandEntry> parseEntriesJson(Map<String, dynamic> root) {
    final list = root['entries'] as List<dynamic>? ?? [];
    return [
      for (final item in list)
        if (item is Map<String, dynamic>) OutdatedBrandEntry.fromJson(item),
    ];
  }

  static const _defaultSeed = [
    OutdatedBrandEntry(
      name: 'Metrash2',
      replacement: 'Metrash',
      since: '2025-03-01',
      sourceLabel:
          'Ministry of Interior announcement, 16 Feb 2025 (Sayeed to attach URL)',
      sourceUrl: '',
      verified: false,
      matchAliases: ['metrash 2', 'metrash2', 'متراش 2', 'متراش٢'],
    ),
  ];
}
