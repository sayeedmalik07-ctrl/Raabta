import 'package:raabta/core/intelligence/capabilities.dart';

/// Canonical Raabta app capabilities — injected into every chat system prompt.
///
/// [compactReference] is generated from [raabtaCapabilities] (source of truth).
/// Do not hand-edit the feature list — update [capabilities.dart] instead.
class RaabtaCapabilitiesReference {
  RaabtaCapabilitiesReference._();

  static String get lastUpdated => '2026-09-22';

  /// One-line per feature + route for navigation guidance — derived from [raabtaCapabilities].
  static String get compactReference => buildCompactReferenceFromCapabilities();

  /// Builds the prompt block programmatically so it cannot drift from [raabtaCapabilities].
  static String buildCompactReferenceFromCapabilities() {
    final buffer = StringBuffer('''
RAABTA APP CAPABILITIES (suggest only when genuinely useful — do not force mentions):
''');

    for (final cap in raabtaCapabilities) {
      buffer.writeln('- ${cap.name} → ${cap.route} — ${cap.description}');
    }

    buffer.writeln('''
When user asks "can Raabta do X?", answer from this list accurately.
If a feature fits their need, name it and give the route path.
''');

    return buffer.toString().trim();
  }
}
