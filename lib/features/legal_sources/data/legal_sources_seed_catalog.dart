import 'package:raabta/features/legal_sources/domain/models/legal_source.dart';

/// Built-in seed catalogue — used when Firestore is empty or offline.
/// Admin updates in `legal_sources` collection override these per document id.
abstract final class LegalSourcesSeedCatalog {
  static const collectionName = 'legal_sources';

  static final List<LegalSource> defaults = [
    LegalSource(
      id: 'law_14_2004',
      lawIdentifier: 'Law No. 14 of 2004',
      shortDescription: 'Qatar Labour Law (core employment rights, gratuity, termination)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_67',
      lawIdentifier: 'Qatar Labour Law No. 14 of 2004, Art. 67',
      shortDescription:
          'Final settlement payment — employer must pay wages and dues before the end of the working day after the contract termination date (or within seven days from the date of leaving Work if the worker left without Article 49 notice)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 15),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_61',
      lawIdentifier: 'Qatar Labour Law No. 14 of 2004, Art. 61',
      shortDescription:
          'Lawful summary dismissal without notice — limited grounds (false identity, gross financial loss reported to Labour Department within 24 hours, repeated safety violations, repeated failure of essential duties after written warning)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 19),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_62',
      lawIdentifier: 'Qatar Labour Law No. 14 of 2004, Art. 62',
      shortDescription:
          'Disciplinary penalty procedure — accusation within 15 days of employer learning of violation; written inquiry (oral for minor breaches); one penalty per violation; penalties only as authorized and per regulations',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 19),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_39',
      lawIdentifier: 'Article 39, Qatar Labour Law No. 14 of 2004 (probation provisions)',
      shortDescription:
          'Probation period — up to 6 months maximum, once per employer; 1-month notice to change employer during probation',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_55',
      lawIdentifier: 'Article 55, Qatar Labour Law No. 14 of 2004',
      shortDescription:
          'Death during employment — employer must deposit wages, earned gratuity, and other entitlements with the court within 15 days with a detailed calculation report; court distributes to heirs under Sharia or personal law applicable in the country of the deceased; unclaimed after 3 years to State public fund; employer bears repatriation of remains unless government arranges and recovers cost',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_57',
      lawIdentifier: 'Article 57, Qatar Labour Law No. 14 of 2004',
      shortDescription:
          'Return travel on termination — employer bears cost to recruitment origin or agreed place; obligation shifts to new employer if worker joins another employer before leaving Qatar',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_64',
      lawIdentifier: 'Qatar Labour Law No. 14 of 2004, Art. 64',
      shortDescription:
          'Dismissal penalty grievance — internal appeal steps; worker may challenge dismissal penalty before competent court/LDRC; if dismissal is arbitrary or violates the law, court may order reinstatement with back wages or appropriate compensation (no fixed formula; at court discretion)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 19),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_110',
      lawIdentifier: 'Article 110, Qatar Labour Law No. 14 of 2004',
      shortDescription:
          'Work-related death compensation — heirs entitled to compensation where the worker dies by reason of the work; amount and process depend on circumstances and investigation findings (separate from Art. 55 wages/gratuity deposit)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_14_2004_art_114',
      lawIdentifier: 'Article 114, Qatar Labour Law No. 14 of 2004',
      shortDescription:
          'Work-related death compensation deposit — employer 15-day court deposit for death compensation following death or investigation result supporting work-related death (separate from Art. 55 entitlements deposit)',
      dateEnacted: DateTime(2004, 6, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_21_2015',
      lawIdentifier: 'Law No. 21 of 2015',
      shortDescription: 'Expatriate entry, exit, and residence (sponsorship)',
      dateEnacted: DateTime(2015, 10, 27),
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_21_2015_residence_cancellation_grace',
      lawIdentifier:
          'Ministry of Interior, Qatar — official operational guidance (June 2026)',
      shortDescription:
          'Authority: MOI Airport Passports Department. Source type: official operational guidance/announcement (15 Jun 2026). Subject: residence-permit cancellation departure period. Current verified rule: leave Qatar within 14 days (previously reported as 30 days). Reported overstay: QAR 10/day. MOI advised checking Metrash before travel. NOT Law 21/2015 Art. 19 — Art. 19\'s 14-day period is the sponsor\'s notification obligation, not the resident\'s departure window. Supersedes legacy MOI/Law 21/2015 web guidance that cited 90 days.',
      dateEnacted: null,
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://portal.moi.gov.qa',
      status: LegalSourceStatus.active,
      effectiveFrom: DateTime(2026, 6, 15),
      supersedes: 'moi_residence_cancellation_departure_legacy_90d',
    ),
    LegalSource(
      id: 'moi_residence_cancellation_departure_legacy_90d',
      lawIdentifier:
          'MOI website — legacy Law 21/2015 residence guidance (outdated)',
      shortDescription:
          'Older MOI web content referring to Law 21/2015 cited a 90-day departure period after residence-permit cancellation — legacy/outdated relative to June 2026 MOI operational guidance (14 days). Do not cite as the current user-facing rule.',
      dateEnacted: DateTime(2015, 10, 27),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://portal.moi.gov.qa',
      status: LegalSourceStatus.superseded,
      supersededBy: 'law_21_2015_residence_cancellation_grace',
    ),
    LegalSource(
      id: 'law_17_2020',
      lawIdentifier: 'Law No. 17 of 2020',
      shortDescription:
          'Minimum wage for all private-sector workers & domestic workers (QAR 1,000 basic + allowances)',
      dateEnacted: DateTime(2020, 8, 30),
      dateLastVerified: DateTime(2026, 8, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'ministerial_decision_17_2021_heat',
      lawIdentifier: 'Ministerial Decision No. 17 of 2021',
      shortDescription:
          'Heat stress protection — outdoor work ban 1 Jun–15 Sep, 10:00–15:30; WBGT stop at 32.1°C',
      dateEnacted: DateTime(2021, 5, 26),
      dateLastVerified: DateTime(2026, 8, 1),
      sourceUrl: 'https://www.mol.gov.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_12_2024_qatarization',
      lawIdentifier: 'Law No. 12 of 2024',
      shortDescription:
          'Qatarization of jobs in the private sector — hiring priority, MoL reporting (quotas via implementing decisions)',
      dateEnacted: DateTime(2024, 10, 17),
      dateLastVerified: DateTime(2026, 8, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
    ),
    LegalSource(
      id: 'law_18_2020',
      lawIdentifier: 'Law No. 18 of 2020',
      shortDescription:
          'Labour Law 14/2004 amendments — resignation/termination written notice (1 month if under 2 years, 2 months if 2+ years). NOT sponsorship/NOC (Law 19/2020).',
      dateEnacted: DateTime(2020, 8, 30),
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_19_2020',
      lawIdentifier: 'Law No. 19 of 2020',
      shortDescription:
          'Amends Law 21/2015 — employer change without NOC (Art. 21), deletes Art. 22; in force 9 Sep 2020. NOT labour notice (Law 18/2020).',
      dateEnacted: DateTime(2020, 8, 30),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'moi_decree_51_2020',
      lawIdentifier: 'Minister of Interior Decree No. (51) of 2020',
      shortDescription:
          'Executive regulation — employer change during permit validity or within 90 days after expiry',
      dateEnacted: DateTime(2020, 8, 19),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://portal.moi.gov.qa',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'cabinet_resolution_6_2018_ldrc',
      lawIdentifier: 'Cabinet Resolution No. 6 of 2018',
      shortDescription:
          'Labour Dispute Resolution Committees (LDRC) — judge-led panels, appeal to Court of Appeal',
      dateEnacted: DateTime(2018, 1, 1),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_17_2018_wsif',
      lawIdentifier: 'Law No. 17 of 2018, Workers\' Support and Insurance Fund',
      shortDescription:
          'Government fund that may pay worker entitlements already decided by the Labour Dispute Resolution Committee when the employer cannot or will not pay — payouts may be capped or interim; verify eligibility on wsif.gov.qa',
      dateEnacted: DateTime(2018, 1, 1),
      dateLastVerified: DateTime(2026, 9, 19),
      sourceUrl: 'https://wsif.gov.qa',
      status: LegalSourceStatus.amended,
    ),
    LegalSource(
      id: 'law_9_2026',
      lawIdentifier: 'Law No. 9 of 2026',
      shortDescription:
          'Amends Law 14/2004 — scope, committees (100+), strike dismissal ground, noncompete (verify articles on Al Meezan)',
      dateEnacted: DateTime(2026, 6, 25),
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
      effectiveFrom: DateTime(2026, 7, 8),
      supersedes: 'law_14_2004',
    ),
    // Tenancy (Law 8/2026) — NOT labour Law 9/2026 (EOSB). Separate records by design.
    LegalSource(
      id: 'law_4_2008_tenancy',
      lawIdentifier: 'Law No. 4 of 2008',
      shortDescription:
          'Property leasing — registration (Art. 3), deposits, Rental Dispute Committee (as amended by Law 8/2026)',
      dateEnacted: DateTime(2008, 1, 1),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
    ),
    LegalSource(
      id: 'law_8_2026_tenancy',
      lawIdentifier: 'Law No. 8 of 2026',
      shortDescription:
          'Amends Law 4/2008 tenancy — QR 250 registration fee (Art. 20(2)), late penalties, Art. 20 bis state sub-leases',
      dateEnacted: DateTime(2026, 3, 1),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
      effectiveFrom: DateTime(2026, 9, 3),
      supersedes: 'law_4_2008_tenancy',
    ),
    LegalSource(
      id: 'law_4_2008_art_10',
      lawIdentifier: 'Article 10, Law No. 4 of 2008 (as amended)',
      shortDescription:
          'Rent increases subject to rules, periods and rates established by Council of Ministers decree (upon Minister proposal) — Art. 10 does not set a fixed percentage; applicable position depends on premises type and relevant decision; disputed increases referred to Rental Disputes Settlement Committee',
      dateEnacted: DateTime(2008, 1, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_4_2008_art_6',
      lawIdentifier: 'Article 6, Law No. 4 of 2008 (as amended)',
      shortDescription:
          'Maintenance obligations — landlord structural duty and tenant routine upkeep; Committee permission required before tenant self-remedy (repair and rent deduction) when landlord refuses necessary repair',
      dateEnacted: DateTime(2008, 1, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_4_2008_art_14',
      lawIdentifier: 'Article 14, Law No. 4 of 2008 (as amended)',
      shortDescription:
          'Subletting — requires landlord written consent; unauthorized subletting can expose main tenant to eviction',
      dateEnacted: DateTime(2008, 1, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_4_2008_eviction_compensation',
      lawIdentifier:
          'Law No. 4 of 2008, Article 19 (as amended by Law No. 20 of 2009) — eviction and compensation',
      shortDescription:
          'Article 19 eviction grounds; Committee vacation order route; licensed additions/modifications with six-month notice from licence date and six-month commencement after vacate; compensation may be sought if warranted when licensed works not carried out or premises re-let first',
      dateEnacted: DateTime(2008, 1, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'ministerial_decision_105_2020_tenancy',
      lawIdentifier: 'Ministerial Decision No. 105 of 2020',
      shortDescription:
          'Worker accommodation in designated family residential areas — restriction on groups of more than five workers; excludes female workers and domestic/comparable household workers from the worker-group definition',
      dateEnacted: DateTime(2020, 1, 1),
      dateLastVerified: DateTime(2026, 9, 20),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'law_22_2021',
      lawIdentifier: 'Law No. 22 of 2021',
      shortDescription:
          'Healthcare Services Law — mandatory expat health insurance, employer-paid premiums (Arts. 10–13; verify on Al Meezan)',
      dateEnacted: DateTime(2021, 12, 23),
      dateLastVerified: DateTime(2026, 6, 1),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
    ),
    LegalSource(
      id: 'law_22_2021_minimum_benefits',
      lawIdentifier: 'Law No. 22 of 2021 — minimum benefits package',
      shortDescription:
          'Mandatory minimum health benefits for employer-sponsored expat coverage (outpatient/inpatient, diagnostics, medicines, maternity baseline, emergency, children to 18). Policy-specific exclusions and sub-limits are insurer-defined — verify your own schedule.',
      dateEnacted: DateTime(2021, 12, 23),
      dateLastVerified: DateTime(2026, 9, 19),
      sourceUrl: 'https://www.almeezan.qa/',
      status: LegalSourceStatus.amended,
    ),
    LegalSource(
      id: 'mol_guidance',
      lawIdentifier: 'Ministry of Labour procedural guidance',
      shortDescription: 'mol.gov.qa procedures, WPS, complaints, Metrash services',
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://www.mol.gov.qa/',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'visa_guides',
      lawIdentifier: 'Visa & Documents step guides',
      shortDescription:
          'MOI residency guides (Iqama, QID, sponsor transfer) cross-referenced with Law 9/2026',
      dateLastVerified: DateTime(2026, 6, 25),
      sourceUrl: 'https://portal.moi.gov.qa',
      status: LegalSourceStatus.active,
    ),
    LegalSource(
      id: 'moi_traffic_19_2007',
      lawIdentifier: 'Traffic Law No. 19 of 2007 (MOI Traffic)',
      shortDescription:
          'Driving licence & Istimara fees, fines, black points, exit blocks (Sep 2024)',
      dateEnacted: DateTime(2007, 6, 12),
      dateLastVerified: DateTime(2026, 7, 28),
      sourceUrl: 'https://portal.moi.gov.qa',
      status: LegalSourceStatus.amended,
    ),
  ];

  /// Most recent verification date across seed defaults (sync fallback).
  static DateTime get seedLatestVerified {
    var latest = DateTime(2000);
    for (final s in defaults) {
      final v = s.dateLastVerified;
      if (v != null && v.isAfter(latest)) latest = v;
    }
    return latest;
  }

  static String get seedLatestVerifiedDisplay =>
      _formatDate(seedLatestVerified);

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
