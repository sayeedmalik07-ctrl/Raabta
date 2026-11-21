/// Bundled or Firestore-cached E-number reference entry.
class ENumberEntry {
  const ENumberEntry({
    required this.code,
    required this.plainName,
    required this.category,
    required this.status,
    required this.reason,
    this.source = ENumberSource.bundled,
  });

  final String code;
  final String plainName;
  final String category;
  /// One of: safe | caution | avoid
  final String status;
  final String reason;
  final ENumberSource source;

  factory ENumberEntry.fromJson(Map<String, dynamic> json) {
    return ENumberEntry(
      code: (json['code'] as String? ?? '').toUpperCase(),
      plainName: json['plainName'] as String? ?? '',
      category: json['category'] as String? ?? 'additive',
      status: json['status'] as String? ?? 'caution',
      reason: json['reason'] as String? ?? '',
      source: ENumberSource.fromStorage(json['source'] as String?),
    );
  }

  factory ENumberEntry.fromFirestore(Map<String, dynamic> data) {
    return ENumberEntry(
      code: (data['code'] as String? ?? '').toUpperCase(),
      plainName: data['plainName'] as String? ?? '',
      category: data['category'] as String? ?? 'additive',
      status: data['status'] as String? ?? 'caution',
      reason: data['reason'] as String? ?? '',
      source: ENumberSource.fromStorage(data['source'] as String?),
    );
  }

  Map<String, dynamic> toFirestore({required String language}) => {
        'code': code,
        'plainName': plainName,
        'category': category,
        'status': status,
        'reason': reason,
        'language': language,
        'source': source.storageValue,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

  ENumberEntry copyWith({
    String? plainName,
    String? reason,
    ENumberSource? source,
  }) {
    return ENumberEntry(
      code: code,
      plainName: plainName ?? this.plainName,
      category: category,
      status: status,
      reason: reason ?? this.reason,
      source: source ?? this.source,
    );
  }
}

enum ENumberSource {
  bundled,
  firestore,
  claudeFallback;

  String get storageValue => switch (this) {
        ENumberSource.bundled => 'bundled',
        ENumberSource.firestore => 'firestore',
        ENumberSource.claudeFallback => 'claude_fallback',
      };

  static ENumberSource fromStorage(String? value) => switch (value) {
        'claude_fallback' => ENumberSource.claudeFallback,
        'firestore' => ENumberSource.firestore,
        _ => ENumberSource.bundled,
      };
}
