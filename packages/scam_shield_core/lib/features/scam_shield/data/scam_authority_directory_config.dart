import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_models.dart';

enum ScamAuthorityCategory {
  government,
  bank,
  telecom,
  utility,
  delivery,
  employer,
}

class ScamAuthorityEntry {
  const ScamAuthorityEntry({
    required this.id,
    required this.category,
    required this.nameKey,
    required this.officialDomains,
    required this.aliases,
    required this.verifyUrl,
  });

  final String id;
  final ScamAuthorityCategory category;
  final String nameKey;
  final List<String> officialDomains;
  final List<String> aliases;
  final String verifyUrl;
}

/// Versioned bundled Qatar authority directory — offline, never AI-generated.
abstract final class ScamAuthorityDirectoryConfig {
  static const version = 1;

  static const entries = <ScamAuthorityEntry>[
    ScamAuthorityEntry(
      id: 'moi',
      category: ScamAuthorityCategory.government,
      nameKey: 'ss_auth_moi',
      officialDomains: ['moi.gov.qa', 'metrash.moi.gov.qa'],
      aliases: ['moi', 'metrash', 'ministry of interior', 'الداخلية'],
      verifyUrl: 'https://www.moi.gov.qa/',
    ),
    ScamAuthorityEntry(
      id: 'hukoomi',
      category: ScamAuthorityCategory.government,
      nameKey: 'ss_auth_hukoomi',
      officialDomains: ['hukoomi.gov.qa', 'portal.www.gov.qa', 'www.gov.qa', 'gov.qa'],
      aliases: ['hukoomi', 'government portal', 'حكومي'],
      verifyUrl: 'https://www.hukoomi.gov.qa/',
    ),
    ScamAuthorityEntry(
      id: 'adlsa',
      category: ScamAuthorityCategory.government,
      nameKey: 'ss_auth_adlsa',
      officialDomains: ['adlsa.gov.qa'],
      aliases: ['adlsa', 'labour', 'labour department'],
      verifyUrl: 'https://www.adlsa.gov.qa/',
    ),
    ScamAuthorityEntry(
      id: 'mol',
      category: ScamAuthorityCategory.government,
      nameKey: 'ss_auth_mol',
      officialDomains: ['mol.gov.qa'],
      aliases: ['mol', 'ministry of labour', 'وزارة العمل'],
      verifyUrl: 'https://www.mol.gov.qa/',
    ),
    ScamAuthorityEntry(
      id: 'nas',
      category: ScamAuthorityCategory.government,
      nameKey: 'ss_auth_nas',
      officialDomains: ['nas.gov.qa'],
      aliases: ['nas', 'national address', 'national address service'],
      verifyUrl: 'https://www.nas.gov.qa/',
    ),
    ScamAuthorityEntry(
      id: 'qnb',
      category: ScamAuthorityCategory.bank,
      nameKey: 'ss_auth_qnb',
      officialDomains: ['qnb.com', 'qnb.com.qa'],
      aliases: ['qnb', 'qatar national bank'],
      verifyUrl: 'https://www.qnb.com.qa/',
    ),
    ScamAuthorityEntry(
      id: 'cbq',
      category: ScamAuthorityCategory.bank,
      nameKey: 'ss_auth_cbq',
      officialDomains: ['cbq.qa'],
      aliases: ['cbq', 'commercial bank'],
      verifyUrl: 'https://www.cbq.qa/',
    ),
    ScamAuthorityEntry(
      id: 'qib',
      category: ScamAuthorityCategory.bank,
      nameKey: 'ss_auth_qib',
      officialDomains: ['qib.com.qa', 'qib.qa'],
      aliases: ['qib', 'qatar islamic bank'],
      verifyUrl: 'https://www.qib.com.qa/',
    ),
    ScamAuthorityEntry(
      id: 'ooredoo',
      category: ScamAuthorityCategory.telecom,
      nameKey: 'ss_auth_ooredoo',
      officialDomains: ['ooredoo.qa'],
      aliases: ['ooredoo'],
      verifyUrl: 'https://www.ooredoo.qa/',
    ),
    ScamAuthorityEntry(
      id: 'vodafone',
      category: ScamAuthorityCategory.telecom,
      nameKey: 'ss_auth_vodafone',
      officialDomains: ['vodafone.qa'],
      aliases: ['vodafone'],
      verifyUrl: 'https://www.vodafone.qa/',
    ),
    ScamAuthorityEntry(
      id: 'kahramaa',
      category: ScamAuthorityCategory.utility,
      nameKey: 'ss_auth_kahramaa',
      officialDomains: ['km.qa', 'kahramaa.com.qa'],
      aliases: ['kahramaa', 'km'],
      verifyUrl: 'https://www.km.qa/',
    ),
  ];

  static ScamAuthorityEntry? findById(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static ScamAuthorityEntry? findByDomain(String domain) {
    final official = OfficialDirectory.lookupByDomain(domain);
    if (official != null) return _fromOfficialEntry(official);
    return null;
  }

  static List<ScamAuthorityEntry> findClaimedInText(String text) {
    final claim = OfficialDirectory.detectClaimedEntity(text, 'English');
    final matches = <ScamAuthorityEntry>[];
    for (final id in claim.matches) {
      final entry = OfficialDirectory.lookupById(id);
      if (entry != null) {
        matches.add(_fromOfficialEntry(entry));
      }
    }
    return matches;
  }

  static ScamAuthorityEntry _fromOfficialEntry(OfficialDirectoryEntry entry) {
    final id =
        entry.authorityRef.isNotEmpty ? entry.authorityRef : entry.id;
    final legacy = findById(id);
    return ScamAuthorityEntry(
      id: id,
      category: legacy?.category ?? _mapCategory(entry.category),
      nameKey: legacy?.nameKey ?? 'ss_auth_$id',
      officialDomains: entry.officialDomains,
      aliases: [...entry.aliases, entry.nameEn, entry.nameAr],
      verifyUrl: legacy?.verifyUrl ??
          (entry.officialDomains.isNotEmpty
              ? 'https://${entry.officialDomains.first}'
              : ''),
    );
  }

  static ScamAuthorityCategory _mapCategory(OfficialDirectoryCategory c) {
    return switch (c) {
      OfficialDirectoryCategory.government =>
        ScamAuthorityCategory.government,
      OfficialDirectoryCategory.banking => ScamAuthorityCategory.bank,
      OfficialDirectoryCategory.telecom => ScamAuthorityCategory.telecom,
      OfficialDirectoryCategory.utilities => ScamAuthorityCategory.utility,
      OfficialDirectoryCategory.airline => ScamAuthorityCategory.employer,
      OfficialDirectoryCategory.health => ScamAuthorityCategory.employer,
      OfficialDirectoryCategory.other => ScamAuthorityCategory.employer,
    };
  }
}

extension ScamAuthorityCategoryX on ScamAuthorityCategory {
  String get labelKey => switch (this) {
        ScamAuthorityCategory.government => 'ss_auth_cat_government',
        ScamAuthorityCategory.bank => 'ss_auth_cat_bank',
        ScamAuthorityCategory.telecom => 'ss_auth_cat_telecom',
        ScamAuthorityCategory.utility => 'ss_auth_cat_utility',
        ScamAuthorityCategory.delivery => 'ss_auth_cat_delivery',
        ScamAuthorityCategory.employer => 'ss_auth_cat_employer',
      };
}
