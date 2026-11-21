import 'package:meta/meta.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_domain_utils.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_models.dart';

class OfficialDirectoryClaimResult {
  const OfficialDirectoryClaimResult({this.matches = const []});

  final List<String> matches;

  String? get primaryId => matches.isEmpty ? null : matches.first;
}

/// Single source of truth for official apps/domains (bundled + optional override).
abstract final class OfficialDirectory {
  static OfficialDirectorySnapshot _snapshot = OfficialDirectorySnapshot.empty;

  static OfficialDirectorySnapshot get snapshot => _snapshot;

  @visibleForTesting
  static void installSnapshot(OfficialDirectorySnapshot snapshot) {
    _snapshot = snapshot;
  }

  static void applySnapshot(OfficialDirectorySnapshot snapshot) {
    if (snapshot.version > _snapshot.version ||
        (_snapshot.version == 0 && snapshot.entries.isNotEmpty)) {
      _snapshot = snapshot;
    }
  }

  static OfficialDirectoryEntry? lookupById(String id) {
    for (final entry in _snapshot.entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static OfficialDirectoryEntry? lookupByDomain(String host) {
    final normalized = OfficialDirectoryDomainUtils.normalizeHost(host);
    for (final entry in _snapshot.verifiedEntries) {
      for (final domain in entry.officialDomains) {
        if (OfficialDirectoryDomainUtils.exactRegistrableMatch(normalized, domain)) {
          return entry;
        }
      }
    }
    return null;
  }

  static bool isKnownLegitimateHost(String host) => lookupByDomain(host) != null;

  static bool detectLookalikeDomain(String host) {
    final normalized = OfficialDirectoryDomainUtils.normalizeHost(host);
    if (lookupByDomain(normalized) != null) return false;

    for (final entry in _snapshot.verifiedEntries) {
      for (final domain in entry.officialDomains) {
        if (OfficialDirectoryDomainUtils.isLookalikeOf(normalized, domain)) {
          return true;
        }
      }
    }
    return _legacyHeuristicLookalike(normalized);
  }

  static OfficialDirectoryClaimResult detectClaimedEntity(
    String text,
    String locale,
  ) {
    final normalized = _normalizeForMatch(text);
    final hits = <String, int>{};

    for (final entry in _snapshot.verifiedEntries) {
      final terms = <String>[
        entry.nameEn,
        entry.nameAr,
        ...entry.aliases,
      ].where((t) => t.trim().isNotEmpty);

      for (final term in terms) {
        if (_matchesTerm(normalized, term)) {
          hits[entry.id] = (hits[entry.id] ?? 0) + 10;
        }
      }
    }

    if (hits.isEmpty) return const OfficialDirectoryClaimResult();

    final sorted = hits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return OfficialDirectoryClaimResult(
      matches: sorted.take(2).map((e) => e.key).toList(growable: false),
    );
  }

  static bool detectSideloadApp(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'https?://[^\s]+\.apk\b', caseSensitive: false).hasMatch(text)) {
      return true;
    }
    if (RegExp(r'\b[\w./\\-]+\.apk\b', caseSensitive: false).hasMatch(text)) {
      return true;
    }
    for (final phrase in _sideloadPhrases) {
      if (lower.contains(phrase)) return true;
    }
    for (final phrase in _sideloadPhrasePatterns) {
      if (RegExp(phrase, caseSensitive: false).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  static List<OfficialDirectoryEntry> search({
    required String query,
    OfficialDirectoryCategory? category,
  }) {
    final q = _normalizeForMatch(query);
    if (q.isEmpty) {
      return _snapshot.entries.where((e) => e.verified).toList();
    }
    return _snapshot.entries.where((entry) {
      if (!entry.verified) return false;
      if (category != null && entry.category != category) return false;
      final haystack = _normalizeForMatch(
        '${entry.nameEn} ${entry.nameAr} ${entry.aliases.join(' ')} ${entry.publisherName}',
      );
      return haystack.contains(q);
    }).toList();
  }

  static bool _legacyHeuristicLookalike(String host) {
    const markers = [
      'qnb-',
      '-qnb',
      'moi-',
      '-moi',
      'gov-',
      'hukoomi-',
      'metrash',
      'adlsa-',
    ];
    return markers.any(host.contains);
  }

  static bool _matchesTerm(String normalizedText, String term) {
    final t = _normalizeForMatch(term);
    if (t.isEmpty) return false;
    if (t.length < 4) {
      return RegExp('\\b${RegExp.escape(t)}\\b', unicode: true)
          .hasMatch(normalizedText);
    }
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(t)) {
      return normalizedText.contains(t);
    }
    return RegExp('\\b${RegExp.escape(t)}\\b', unicode: true)
        .hasMatch(normalizedText);
  }

  static String _normalizeForMatch(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    s = s.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    s = s.replaceAll('ى', 'ي').replaceAll('ة', 'ه');
    return s;
  }

  static const _sideloadPhrases = [
    'install the app from this link',
    'update the app from this link',
    'download the app from this link',
    'install app from link',
    'download apk',
    'install apk',
    'تحميل التطبيق من الرابط',
    'ثبت التطبيق',
    'نزّل التطبيق',
    'install from telegram',
    'install from whatsapp',
  ];

  static const _sideloadPhrasePatterns = [
    r'install.{0,24}app.{0,24}link',
    r'download.{0,24}\.apk',
    r'अपडेट.{0,20}ऐप',
    r'ऐप.{0,20}लिंक',
  ];
}
