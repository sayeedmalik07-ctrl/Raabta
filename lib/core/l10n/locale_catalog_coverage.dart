/// Shared helper for [localeCoverageReport] on string catalogs.
///
/// Each catalog exposes its own `@visibleForTesting localeCoverageReport` getter
/// (same pattern as [AppShellStrings]) that delegates here — keeps one algorithm,
/// consistent report shape across catalogs.
Map<String, Set<String>> buildLocaleCoverageReport({
  required Map<String, Map<String, String>> catalog,
  required List<String> supportedLocales,
  bool fillMissingWithEnglish = true,
}) {
  final source = fillMissingWithEnglish
      ? withFullLocaleCoverage(
          catalog: catalog,
          supportedLocales: supportedLocales,
        )
      : catalog;
  final report = <String, Set<String>>{};
  for (final entry in source.entries) {
    final missing = supportedLocales
        .where((locale) => !(entry.value[locale]?.isNotEmpty ?? false))
        .toSet();
    if (missing.isNotEmpty) report[entry.key] = missing;
  }
  return report;
}

/// Ensures every supported locale has a non-empty string (English fallback).
Map<String, Map<String, String>> withFullLocaleCoverage({
  required Map<String, Map<String, String>> catalog,
  required List<String> supportedLocales,
}) {
  return catalog.map((key, locales) {
    final english = locales['English'] ?? key;
    final filled = <String, String>{};
    for (final locale in supportedLocales) {
      final value = locales[locale];
      filled[locale] =
          value != null && value.isNotEmpty ? value : english;
    }
    return MapEntry(key, filled);
  });
}
