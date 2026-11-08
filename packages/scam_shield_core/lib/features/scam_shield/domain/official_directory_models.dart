enum OfficialDirectoryCategory {
  government,
  banking,
  telecom,
  airline,
  utilities,
  health,
  other,
}

class OfficialDirectoryEntry {
  const OfficialDirectoryEntry({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameAr,
    required this.aliases,
    required this.publisherName,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.officialDomains,
    required this.authorityRef,
    required this.officialSenders,
    required this.contactChannelNote,
    required this.channelSourceUrl,
    required this.lastVerified,
    required this.verified,
  });

  final String id;
  final OfficialDirectoryCategory category;
  final String nameEn;
  final String nameAr;
  final List<String> aliases;
  final String publisherName;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final List<String> officialDomains;
  final String authorityRef;
  final List<String> officialSenders;
  final Map<String, String> contactChannelNote;
  final String channelSourceUrl;
  final DateTime? lastVerified;
  final bool verified;

  bool get isStale {
    if (lastVerified == null) return false;
    return DateTime.now().difference(lastVerified!).inDays > 180;
  }

  String displayName(String locale) {
    if (locale == 'Arabic' && nameAr.trim().isNotEmpty) return nameAr;
    return nameEn;
  }

  String? contactNote(String locale) {
    return contactChannelNote[locale] ??
        contactChannelNote['English'] ??
        contactChannelNote.values.firstOrNull;
  }

  factory OfficialDirectoryEntry.fromJson(Map<String, dynamic> json) {
    final noteRaw = json['contactChannelNote'];
    final notes = <String, String>{};
    if (noteRaw is Map) {
      noteRaw.forEach((k, v) => notes[k.toString()] = v.toString());
    } else if (noteRaw is String && noteRaw.isNotEmpty) {
      notes['English'] = noteRaw;
    }

    DateTime? verifiedDate;
    final lv = json['lastVerified']?.toString() ?? '';
    if (lv.isNotEmpty) {
      verifiedDate = DateTime.tryParse(lv);
    }

    return OfficialDirectoryEntry(
      id: json['id']?.toString() ?? '',
      category: OfficialDirectoryCategoryX.fromRaw(json['category']?.toString()),
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      aliases: (json['aliases'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      publisherName: json['publisherName']?.toString() ?? '',
      androidStoreUrl: json['androidStoreUrl']?.toString() ?? '',
      iosStoreUrl: json['iosStoreUrl']?.toString() ?? '',
      officialDomains: (json['officialDomains'] as List<dynamic>? ?? [])
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList(),
      authorityRef: json['authorityRef']?.toString() ?? '',
      officialSenders: (json['officialSenders'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      contactChannelNote: notes,
      channelSourceUrl: json['channelSourceUrl']?.toString() ?? '',
      lastVerified: verifiedDate,
      verified: json['verified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'aliases': aliases,
        'publisherName': publisherName,
        'androidStoreUrl': androidStoreUrl,
        'iosStoreUrl': iosStoreUrl,
        'officialDomains': officialDomains,
        'authorityRef': authorityRef,
        'officialSenders': officialSenders,
        'contactChannelNote': contactChannelNote,
        'channelSourceUrl': channelSourceUrl,
        'lastVerified': lastVerified?.toIso8601String().split('T').first ?? '',
        'verified': verified,
      };
}

class OfficialDirectorySnapshot {
  const OfficialDirectorySnapshot({
    required this.version,
    required this.entries,
  });

  final int version;
  final List<OfficialDirectoryEntry> entries;

  static const empty = OfficialDirectorySnapshot(version: 0, entries: []);

  List<OfficialDirectoryEntry> get verifiedEntries =>
      entries.where((e) => e.verified).toList(growable: false);
}

extension OfficialDirectoryCategoryX on OfficialDirectoryCategory {
  static OfficialDirectoryCategory fromRaw(String? raw) {
    return OfficialDirectoryCategory.values.firstWhere(
      (c) => c.name == raw,
      orElse: () => OfficialDirectoryCategory.other,
    );
  }

  String get labelKey => switch (this) {
        OfficialDirectoryCategory.government => 'ss_official_dir_cat_government',
        OfficialDirectoryCategory.banking => 'ss_official_dir_cat_banking',
        OfficialDirectoryCategory.telecom => 'ss_official_dir_cat_telecom',
        OfficialDirectoryCategory.airline => 'ss_official_dir_cat_airline',
        OfficialDirectoryCategory.utilities => 'ss_official_dir_cat_utilities',
        OfficialDirectoryCategory.health => 'ss_official_dir_cat_health',
        OfficialDirectoryCategory.other => 'ss_official_dir_cat_other',
      };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
