import 'disruption_official_links.dart';
import 'disruption_readiness_models.dart';

/// Single bundled catalog for all disruption entry points.
abstract final class DisruptionReadinessCatalog {
  static const goBagItemIds = [
    'passport',
    'qid',
    'contract',
    'salary_slips',
    'medicines',
    'charger_power_bank',
    'cash',
    'vault_copies',
    'contacts_written',
  ];

  static final blocks = <DisruptionContentBlock>[
    DisruptionContentBlock(
      id: 'live_status_disclaimer',
      titleKey: 'dr_block_disclaimer_title',
      bodyKey: 'dr_block_disclaimer_body',
      publicationStatus: DisruptionPublicationStatus.published,
      profiles: DisruptionEntryProfile.values,
    ),
    DisruptionContentBlock(
      id: 'early_warning_channel',
      titleKey: 'dr_block_ews_channel_title',
      bodyKey: 'dr_block_ews_channel_body',
      publicationStatus: DisruptionPublicationStatus.published,
      source: DisruptionOfficialSourceRef(
        nameKey: 'dr_source_moi',
        officialUrl: DisruptionOfficialLinks.moiEarlyWarningPortal,
        lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
        verification: DisruptionSourceVerification.verified,
      ),
      links: [
        DisruptionExternalLink(
          labelKey: 'dr_link_moi_ews',
          officialUrl: DisruptionOfficialLinks.moiEarlyWarningPortal,
          lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
          verification: DisruptionSourceVerification.verified,
        ),
        DisruptionExternalLink(
          labelKey: 'dr_link_moi_portal',
          officialUrl: DisruptionOfficialLinks.moiPortal,
          lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
          verification: DisruptionSourceVerification.verified,
        ),
      ],
      profiles: [
        DisruptionEntryProfile.knowQatar,
        DisruptionEntryProfile.leavingQatar,
      ],
    ),
    DisruptionContentBlock(
      id: 'gco_response_guidance',
      titleKey: 'dr_block_gco_pending_title',
      bodyKey: 'dr_block_gco_pending_body',
      publicationStatus: DisruptionPublicationStatus.draft,
      source: DisruptionOfficialSourceRef(
        nameKey: 'dr_source_gco',
        lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
        verification: DisruptionSourceVerification.unavailable,
      ),
      profiles: [DisruptionEntryProfile.knowQatar],
    ),
    DisruptionContentBlock(
      id: 'before_airport',
      titleKey: 'dr_block_before_airport_title',
      bodyKey: 'dr_block_before_airport_body',
      publicationStatus: DisruptionPublicationStatus.published,
      source: DisruptionOfficialSourceRef(
        nameKey: 'dr_source_qcaa',
        officialUrl: DisruptionOfficialLinks.qcaaEn,
        lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
        verification: DisruptionSourceVerification.verified,
      ),
      links: [
        DisruptionExternalLink(
          labelKey: 'dr_link_hamad_airport',
          officialUrl: DisruptionOfficialLinks.hamadAirport,
          lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
          verification: DisruptionSourceVerification.verified,
        ),
        DisruptionExternalLink(
          labelKey: 'dr_link_qcaa',
          officialUrl: DisruptionOfficialLinks.qcaaEn,
          lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
          verification: DisruptionSourceVerification.verified,
        ),
      ],
      profiles: [
        DisruptionEntryProfile.leavingQatar,
        DisruptionEntryProfile.tripPlanner,
        DisruptionEntryProfile.knowQatar,
      ],
    ),
    DisruptionContentBlock(
      id: 'keep_records',
      titleKey: 'dr_block_keep_records_title',
      bodyKey: 'dr_block_keep_records_body',
      publicationStatus: DisruptionPublicationStatus.published,
      profiles: [
        DisruptionEntryProfile.leavingQatar,
        DisruptionEntryProfile.tripPlanner,
      ],
    ),
    DisruptionContentBlock(
      id: 'go_bag',
      titleKey: 'dr_block_go_bag_title',
      bodyKey: 'dr_block_go_bag_body',
      publicationStatus: DisruptionPublicationStatus.published,
      profiles: DisruptionEntryProfile.values,
    ),
    DisruptionContentBlock(
      id: 'evacuation_scams',
      titleKey: 'dr_block_evacuation_scams_title',
      bodyKey: 'dr_block_evacuation_scams_body',
      publicationStatus: DisruptionPublicationStatus.published,
      source: DisruptionOfficialSourceRef(
        nameKey: 'dr_source_moi',
        officialUrl: DisruptionOfficialLinks.moiPortal,
        lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
        verification: DisruptionSourceVerification.verified,
      ),
      profiles: [
        DisruptionEntryProfile.leavingQatar,
        DisruptionEntryProfile.knowQatar,
      ],
    ),
    DisruptionContentBlock(
      id: 'embassy',
      titleKey: 'dr_block_embassy_title',
      bodyKey: 'dr_block_embassy_body',
      publicationStatus: DisruptionPublicationStatus.published,
      profiles: [
        DisruptionEntryProfile.leavingQatar,
        DisruptionEntryProfile.knowQatar,
      ],
    ),
    DisruptionContentBlock(
      id: 'emergency_999',
      titleKey: 'dr_block_emergency_title',
      bodyKey: 'dr_block_emergency_body',
      publicationStatus: DisruptionPublicationStatus.published,
      profiles: [
        DisruptionEntryProfile.knowQatar,
        DisruptionEntryProfile.leavingQatar,
        DisruptionEntryProfile.tripPlanner,
      ],
    ),
    DisruptionContentBlock(
      id: 'rp_neutral_note',
      titleKey: 'dr_block_rp_neutral_title',
      bodyKey: 'dr_block_rp_neutral_body',
      publicationStatus: DisruptionPublicationStatus.published,
      source: DisruptionOfficialSourceRef(
        nameKey: 'dr_source_moi',
        officialUrl: DisruptionOfficialLinks.metrashPortal,
        lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
        verification: DisruptionSourceVerification.verified,
      ),
      links: [
        DisruptionExternalLink(
          labelKey: 'dr_link_metrash',
          officialUrl: DisruptionOfficialLinks.metrashPortal,
          lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
          verification: DisruptionSourceVerification.verified,
        ),
      ],
      profiles: [DisruptionEntryProfile.leavingQatar],
    ),
  ];

  static List<DisruptionContentBlock> publishedFor(DisruptionEntryProfile profile) {
    return blocks
        .where((b) => b.isPublished && b.appliesTo(profile))
        .toList(growable: false);
  }

  static DisruptionContentBlock? blockById(String id) {
    for (final block in blocks) {
      if (block.id == id) return block;
    }
    return null;
  }
}

abstract final class DisruptionEmbassyCatalog {
  static const india = DisruptionEmbassyCountryEntry(
    countryId: 'india',
    status: DisruptionEmbassyPortalStatus.verified,
    portalUrl: DisruptionOfficialLinks.indiaMadad,
    authorityNameKey: 'dr_embassy_india_authority',
    lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
  );

  static const nepal = DisruptionEmbassyCountryEntry(
    countryId: 'nepal',
    status: DisruptionEmbassyPortalStatus.verified,
    portalUrl: DisruptionOfficialLinks.nepalConsular,
    authorityNameKey: 'dr_embassy_nepal_authority',
    lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
  );

  static const philippines = DisruptionEmbassyCountryEntry(
    countryId: 'philippines',
    status: DisruptionEmbassyPortalStatus.verified,
    portalUrl: DisruptionOfficialLinks.philippinesDmw,
    authorityNameKey: 'dr_embassy_ph_authority',
    lastVerifiedIso: DisruptionOfficialLinks.lastVerifiedIso,
  );

  static const bangladesh = DisruptionEmbassyCountryEntry(
    countryId: 'bangladesh',
    status: DisruptionEmbassyPortalStatus.notYetConfirmed,
    notConfirmedReasonKey: 'dr_embassy_bd_not_confirmed',
  );

  static const pakistan = DisruptionEmbassyCountryEntry(
    countryId: 'pakistan',
    status: DisruptionEmbassyPortalStatus.notYetConfirmed,
    notConfirmedReasonKey: 'dr_embassy_pk_not_confirmed',
  );

  static const sriLanka = DisruptionEmbassyCountryEntry(
    countryId: 'sri_lanka',
    status: DisruptionEmbassyPortalStatus.notYetConfirmed,
    notConfirmedReasonKey: 'dr_embassy_lk_not_confirmed',
  );

  static const countries = [
    india,
    nepal,
    philippines,
    bangladesh,
    pakistan,
    sriLanka,
  ];

  static DisruptionEmbassyCountryEntry? forCountryId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final normalized = id.trim().toLowerCase().replaceAll(' ', '_');
    for (final entry in countries) {
      if (entry.countryId == normalized) return entry;
    }
    return null;
  }
}
