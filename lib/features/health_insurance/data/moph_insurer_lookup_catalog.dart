import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';

/// Bundled MOPH insurer + TPA/plan lookup — admin-updatable via Firestore
/// `legal_sources/moph_insurers` (same freshness pattern as legal_sources).
abstract final class MophInsurerLookupCatalog {
  static const firestoreDocId = 'moph_insurers';

  /// Verified against MOPH HFID participant list (July 2024 PDF) — confirm
  /// currency on https://www.moph.gov.qa before shipping updates.
  static const defaultInsurers = <String>[
    'Alkoot Insurance & Reinsurance',
    'Alkhaleej Takaful Insurance',
    'Al Arabia Insurance Company',
    'Damaan Islamic Insurance Company (Beema)',
    'Doha Insurance Group',
    'Doha Takaful W.L.L',
    'General Takaful Company',
    'GIG Gulf',
    'Libano-Suisse Insurance Company',
    'QLM Life & Medical Insurance Company',
    'Qatar General Insurance and Reinsurance Company',
    'Qatar Insurance Company',
    'Qatar Islamic Insurance Group',
    'Seib Insurance & Reinsurance Company',
    'Sharq Insurance Company',
  ];

  /// Common card / HR shorthand → canonical MOPH legal name.
  static const defaultInsurerAliases = <String, String>{
    'qic': 'Qatar Insurance Company',
    'qatar insurance company q.s.p.c': 'Qatar Insurance Company',
    'qatar insurance company q.s.p.c.': 'Qatar Insurance Company',
    'gig': 'GIG Gulf',
    'gig gulf': 'GIG Gulf',
    'axa': 'GIG Gulf',
    'axa gulf': 'GIG Gulf',
    'axa insurance': 'GIG Gulf',
    'beema': 'Damaan Islamic Insurance Company (Beema)',
    'damaan': 'Damaan Islamic Insurance Company (Beema)',
    'qatar islamic insurance company': 'Qatar Islamic Insurance Group',
    'qiic': 'Qatar Islamic Insurance Group',
    'qlm': 'QLM Life & Medical Insurance Company',
    'alkoot': 'Alkoot Insurance & Reinsurance',
    'qatar general insurance': 'Qatar General Insurance and Reinsurance Company',
    'qatar general insurance and reinsurance': 'Qatar General Insurance and Reinsurance Company',
    'seib': 'Seib Insurance & Reinsurance Company',
  };

  static const defaultTpaMappings = <TpaOrPlanMapping>[
    TpaOrPlanMapping(
      id: 'globemed',
      displayName: 'GlobeMed',
      type: 'tpa',
      underlyingInsurers: [],
      aliases: ['globe med', 'globemed qatar', 'globemed network'],
      notes:
          'Third-Party Administrator (TPA) — administers claims on behalf of various underlying insurers; not itself a MOPH-licensed insurer.',
    ),
    TpaOrPlanMapping(
      id: 'balsam',
      displayName: 'Balsam',
      type: 'brandedPlan',
      underlyingInsurers: ['Qatar Islamic Insurance Group'],
      aliases: ['balsam plan', 'balsam health', 'balsam insurance'],
      notes: 'Branded plan issued by Qatar Islamic Insurance Group.',
    ),
    TpaOrPlanMapping(
      id: 'nextcare',
      displayName: 'NextCare',
      type: 'tpa',
      underlyingInsurers: [],
      aliases: ['next care', 'nextcare qatar'],
      notes: 'TPA — underlying insurer depends on employer contract; confirm with HR.',
    ),
  ];

  /// QFC-registered insurers — complaints route to QFCRA CDRS, not QCB.
  static const defaultQfcRegisteredInsurers = <String>[
    'Zurich International Life Limited',
    'Zurich Insurance Company Ltd (QFC Branch)',
  ];

  /// Canonical insurer name → regulatory body (`qcb` default if absent).
  static const defaultInsurerRegulatoryBodies = <String, String>{
    'Zurich International Life Limited': 'qfcra',
    'Zurich Insurance Company Ltd (QFC Branch)': 'qfcra',
  };

  static DateTime get seedLastVerified => DateTime(2026, 8, 1);

  static String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
