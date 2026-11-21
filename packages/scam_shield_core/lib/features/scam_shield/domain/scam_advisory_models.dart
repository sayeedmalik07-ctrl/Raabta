enum ScamAdvisoryStatus { draft, published }

enum ScamAdvisorySeverity { info, elevated }

/// Categories: Phase 6 archetype ids where they fit, plus editorial extensions.
abstract final class ScamAdvisoryCategories {
  static const govtImpersonation = 'govt_impersonation';
  static const fakeApp = 'fake_app';
  static const vendorInvoice = 'vendor_invoice';
  static const moneyMule = 'money_mule';
  static const other = 'other';
}

class ScamAdvisory {
  const ScamAdvisory({
    required this.id,
    required this.status,
    required this.severity,
    required this.category,
    required this.title,
    required this.summary,
    required this.redFlags,
    required this.whatToDo,
    required this.claimedEntityIds,
    required this.matchPhrases,
    required this.samplePattern,
    required this.authorityRefs,
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceDate,
    required this.publishedAt,
    required this.expiresAt,
  });

  final String id;
  final ScamAdvisoryStatus status;
  final ScamAdvisorySeverity severity;
  final String category;
  final String title;
  final String summary;
  final List<String> redFlags;
  final Map<String, String> whatToDo;
  final List<String> claimedEntityIds;
  final Map<String, List<String>> matchPhrases;
  final String samplePattern;
  final List<String> authorityRefs;
  final String sourceName;
  final String sourceUrl;
  final DateTime? sourceDate;
  final DateTime? publishedAt;
  final DateTime expiresAt;

  bool get isActive =>
      status == ScamAdvisoryStatus.published &&
      expiresAt.isAfter(DateTime.now());

  String whatToDoForLocale(String locale) {
    return whatToDo[locale] ??
        whatToDo['English'] ??
        whatToDo.values.firstOrNull ??
        '';
  }

  List<String> phrasesForLocale(String locale) {
    return matchPhrases[locale] ??
        matchPhrases['English'] ??
        const [];
  }

  factory ScamAdvisory.fromMap(String id, Map<String, dynamic> data) {
    return ScamAdvisory(
      id: id,
      status: _statusFromRaw(data['status']?.toString()),
      severity: data['severity']?.toString() == 'elevated'
          ? ScamAdvisorySeverity.elevated
          : ScamAdvisorySeverity.info,
      category: data['category']?.toString() ?? ScamAdvisoryCategories.other,
      title: data['title']?.toString() ?? '',
      summary: data['summary']?.toString() ?? '',
      redFlags: _stringList(data['redFlags']),
      whatToDo: _stringMap(data['whatToDo']),
      claimedEntityIds: _stringList(data['claimedEntityIds']),
      matchPhrases: _phraseMap(data['matchPhrases']),
      samplePattern: data['samplePattern']?.toString() ?? '',
      authorityRefs: _stringList(data['authorityRefs']),
      sourceName: data['sourceName']?.toString() ?? '',
      sourceUrl: data['sourceUrl']?.toString() ?? '',
      sourceDate: _parseDateField(data['sourceDate']),
      publishedAt: _parseDateField(data['publishedAt']),
      expiresAt: _parseDateField(data['expiresAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'severity': severity.name,
        'category': category,
        'title': title,
        'summary': summary,
        'redFlags': redFlags,
        'whatToDo': whatToDo,
        'claimedEntityIds': claimedEntityIds,
        'matchPhrases': matchPhrases,
        'samplePattern': samplePattern,
        'authorityRefs': authorityRefs,
        'sourceName': sourceName,
        'sourceUrl': sourceUrl,
        'sourceDate': sourceDate?.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static Map<String, List<String>> _phraseMap(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, List<String>>{};
    raw.forEach((k, v) {
      if (v is List) {
        out[k.toString()] = v.map((e) => e.toString()).toList();
      }
    });
    return out;
  }

  static DateTime? _parseDateField(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static ScamAdvisoryStatus _statusFromRaw(String? raw) {
    if (raw == 'published') return ScamAdvisoryStatus.published;
    return ScamAdvisoryStatus.draft;
  }
}

class ScamAdvisoryMatch {
  const ScamAdvisoryMatch({
    required this.advisoryId,
    required this.score,
  });

  final String advisoryId;
  final int score;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
