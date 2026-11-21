import 'models/home_country_support_models.dart';
import 'models/return_support_models.dart';

/// Shared client-side migrant support config — home-country resources (Part A)
/// and Before You Sign checklists (Part B). Extend [countries] for new origins.
abstract final class MigrantSupportCatalog {
  static const List<HomeCountrySupportCountryDef> countries = [
    india,
    nepal,
    philippines,
  ];

  /// Qatar-side verification channels — shared across all origin countries.
  static const qatarVerificationChannels = [
    HomeCountrySupportResourceDef(
      id: 'qvc',
      titleKey: 'eosb_bys_qvc_title',
      descriptionKey: 'eosb_bys_qvc_desc',
      url: 'https://www.qatarvisacenter.com',
      needsVerification: true,
    ),
    HomeCountrySupportResourceDef(
      id: 'moi_visa',
      titleKey: 'eosb_bys_moi_title',
      descriptionKey: 'eosb_bys_moi_desc',
      url: 'https://portal.moi.gov.qa',
      needsVerification: true,
    ),
  ];

  /// Universal job-offer authenticity checklist — shown once for all countries.
  static const offerAuthenticityChecklist = OfferAuthenticityChecklistDef(
    introKey: 'eosb_bys_offer_real_intro',
    communicationRedFlagKeys: [
      'eosb_bys_offer_comm_no_call',
      'eosb_bys_offer_comm_messaging_only',
      'eosb_bys_offer_comm_free_email',
      'eosb_bys_offer_comm_pressure',
    ],
    paymentRedFlagKeys: [
      'eosb_bys_offer_pay_before_contract',
      'eosb_bys_offer_pay_untraceable',
      'eosb_bys_offer_pay_fee_mismatch',
    ],
    documentationRedFlagKeys: [
      'eosb_bys_offer_doc_no_contract',
      'eosb_bys_offer_doc_informal_only',
      'eosb_bys_offer_doc_no_registration',
      'eosb_bys_offer_doc_vague_details',
    ],
    verificationActionKeys: [
      'eosb_bys_offer_verify_agency',
      'eosb_bys_offer_verify_employer',
      'eosb_bys_offer_verify_contract',
    ],
  );

  /// Qatar-side labour complaint & dispute channels (MoL/ADLSA) — flat static config.
  ///
  /// Content aligned with [qatar_labour_law_kb.dart] complaints section and
  /// Raabta AI Central Brain dispute routing (16008, mol.gov.qa, SMS 92727, NAS).
  static const qatarProcedureChannels = [
    HomeCountrySupportResourceDef(
      id: 'mol_unified_complaints',
      titleKey: 'eosb_qatar_ucp_title',
      descriptionKey: 'eosb_qatar_ucp_desc',
      url: 'https://www.mol.gov.qa',
    ),
    HomeCountrySupportResourceDef(
      id: 'adlsa_sms_complaint',
      titleKey: 'eosb_qatar_sms_title',
      descriptionKey: 'eosb_qatar_sms_desc',
      contacts: [
        HomeCountrySupportContactDef(
          labelKey: 'eosb_qatar_sms_format_label',
          value: 'eosb_qatar_sms_format_value',
          type: HomeCountrySupportContactType.text,
        ),
        HomeCountrySupportContactDef(
          labelKey: 'eosb_hcs_contact_phone',
          value: '92727',
          type: HomeCountrySupportContactType.phone,
        ),
      ],
    ),
    HomeCountrySupportResourceDef(
      id: 'adlsa_helpline',
      titleKey: 'eosb_qatar_16008_title',
      descriptionKey: 'eosb_qatar_16008_desc',
      contacts: [
        HomeCountrySupportContactDef(
          labelKey: 'eosb_hcs_contact_phone',
          value: '16008',
          type: HomeCountrySupportContactType.phone,
        ),
        HomeCountrySupportContactDef(
          labelKey: 'eosb_hcs_contact_hours',
          value: 'eosb_qatar_16008_hours_value',
          type: HomeCountrySupportContactType.text,
        ),
      ],
    ),
    HomeCountrySupportResourceDef(
      id: 'nas_login',
      titleKey: 'eosb_qatar_nas_title',
      descriptionKey: 'eosb_qatar_nas_desc',
      url: 'https://www.mol.gov.qa',
    ),
  ];

  static const india = HomeCountrySupportCountryDef(
    countryId: 'india',
    displayNameKey: 'eosb_hcs_country_india',
    nationalityAliases: [
      'india',
      'indian',
      'in',
      'ind',
      'bharat',
      'hindustan',
      'भारत',
      'india (indian)',
    ],
    nationalResources: [
      HomeCountrySupportResourceDef(
        id: 'emigrate',
        titleKey: 'eosb_hcs_emigrate_title',
        descriptionKey: 'eosb_hcs_emigrate_desc',
        url: 'https://emigrate.gov.in',
      ),
      HomeCountrySupportResourceDef(
        id: 'madad',
        titleKey: 'eosb_hcs_madad_title',
        descriptionKey: 'eosb_hcs_madad_desc',
        url: 'https://madad.gov.in',
      ),
      HomeCountrySupportResourceDef(
        id: 'india_embassy_labour',
        titleKey: 'eosb_hcs_india_embassy_title',
        descriptionKey: 'eosb_hcs_india_embassy_desc',
        contacts: [
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_address',
            value:
                'Villa No. 86 & 90, Street 941, Al Eithra Street, Zone 63, Onaiza, Doha',
            type: HomeCountrySupportContactType.text,
          ),
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_labour_phone',
            value: '+97444255714',
            type: HomeCountrySupportContactType.phone,
          ),
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_labour_phone_alt',
            value: '+97444255724',
            type: HomeCountrySupportContactType.phone,
          ),
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_labour_email',
            value: 'labour.doha@mea.gov.in',
            type: HomeCountrySupportContactType.email,
          ),
        ],
      ),
      HomeCountrySupportResourceDef(
        id: 'pbsk',
        titleKey: 'eosb_hcs_pbsk_title',
        descriptionKey: 'eosb_hcs_pbsk_desc',
        contacts: [
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_phone',
            value: '+97444953500',
            type: HomeCountrySupportContactType.phone,
          ),
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_hours',
            value: 'eosb_hcs_pbsk_hours_value',
            type: HomeCountrySupportContactType.text,
          ),
        ],
      ),
    ],
    regions: {
      'kerala': HomeCountrySupportRegionDef(
        regionId: 'kerala',
        titleKey: 'eosb_hcs_kerala_section_title',
        regionAliases: ['kerala', 'kl', 'ker', 'keralite'],
        resources: [
          HomeCountrySupportResourceDef(
            id: 'norka_care',
            titleKey: 'eosb_hcs_norka_care_title',
            descriptionKey: 'eosb_hcs_norka_care_desc',
            needsVerification: true,
          ),
          HomeCountrySupportResourceDef(
            id: 'ndprem',
            titleKey: 'eosb_hcs_ndprem_title',
            descriptionKey: 'eosb_hcs_ndprem_desc',
            needsVerification: true,
          ),
          HomeCountrySupportResourceDef(
            id: 'pravasi_legal_aid',
            titleKey: 'eosb_hcs_pravasi_legal_aid_title',
            descriptionKey: 'eosb_hcs_pravasi_legal_aid_desc',
            needsVerification: true,
          ),
        ],
      ),
    },
    beforeYouSign: BeforeYouSignChecklistDef(
      maxFeeRuleKey: 'eosb_bys_india_fee',
      maxFeeNeedsVerification: false,
      staleWarningKey: 'eosb_bys_india_fee_bill_warning',
      staleWarningNeedsVerification: true,
      redFlagKeys: [
        'eosb_bys_india_flag_pay_before_contract',
        'eosb_bys_india_flag_no_written_contract',
        'eosb_bys_india_flag_agency_not_emigrate',
        'eosb_bys_india_flag_emigration_not_cleared',
      ],
      originVerificationChannels: [
        HomeCountrySupportResourceDef(
          id: 'emigrate_verify',
          titleKey: 'eosb_bys_india_emigrate_link_title',
          descriptionKey: 'eosb_bys_india_emigrate_link_desc',
          url: 'https://emigrate.gov.in',
        ),
      ],
    ),
  );

  static const nepal = HomeCountrySupportCountryDef(
    countryId: 'nepal',
    displayNameKey: 'eosb_hcs_country_nepal',
    nationalityAliases: [
      'nepal',
      'nepali',
      'nepalese',
      'np',
      'नेपाल',
    ],
    nationalResources: [
      HomeCountrySupportResourceDef(
        id: 'dofa',
        titleKey: 'eosb_hcs_nepal_dofa_title',
        descriptionKey: 'eosb_hcs_nepal_dofa_desc',
        url: 'https://dofe.gov.np',
        needsVerification: true,
      ),
      HomeCountrySupportResourceDef(
        id: 'feb',
        titleKey: 'eosb_hcs_nepal_feb_title',
        descriptionKey: 'eosb_hcs_nepal_feb_desc',
        needsVerification: true,
      ),
      HomeCountrySupportResourceDef(
        id: 'nepal_pre_departure_note',
        titleKey: 'eosb_hcs_nepal_pre_departure_title',
        descriptionKey: 'eosb_hcs_nepal_pre_departure_desc',
        needsVerification: true,
      ),
    ],
    beforeYouSign: BeforeYouSignChecklistDef(
      maxFeeRuleKey: 'eosb_bys_nepal_fee',
      maxFeeNeedsVerification: true,
      redFlagKeys: [
        'eosb_bys_nepal_flag_pay_before_permit',
        'eosb_bys_nepal_flag_no_orientation',
        'eosb_bys_nepal_flag_agency_not_feims',
        'eosb_bys_nepal_flag_no_written_contract',
      ],
      originVerificationChannels: [
        HomeCountrySupportResourceDef(
          id: 'feims_verify',
          titleKey: 'eosb_bys_nepal_feims_link_title',
          descriptionKey: 'eosb_bys_nepal_feims_link_desc',
          url: 'https://feims.dofe.gov.np',
          needsVerification: true,
        ),
      ],
    ),
  );

  static const philippines = HomeCountrySupportCountryDef(
    countryId: 'philippines',
    displayNameKey: 'eosb_hcs_country_philippines',
    nationalityAliases: [
      'philippines',
      'filipino',
      'filipina',
      'philippine',
      'ph',
      'pilipinas',
      'ofw',
    ],
    nationalResources: [
      HomeCountrySupportResourceDef(
        id: 'dmw',
        titleKey: 'eosb_hcs_ph_dmw_title',
        descriptionKey: 'eosb_hcs_ph_dmw_desc',
        url: 'https://www.dmw.gov.ph',
        needsVerification: true,
        contacts: [
          HomeCountrySupportContactDef(
            labelKey: 'eosb_hcs_contact_hotline',
            value: '1348',
            type: HomeCountrySupportContactType.phone,
          ),
        ],
      ),
      HomeCountrySupportResourceDef(
        id: 'owwa',
        titleKey: 'eosb_hcs_ph_owwa_title',
        descriptionKey: 'eosb_hcs_ph_owwa_desc',
        url: 'https://owwa.gov.ph',
        needsVerification: true,
      ),
      HomeCountrySupportResourceDef(
        id: 'mwo',
        titleKey: 'eosb_hcs_ph_mwo_title',
        descriptionKey: 'eosb_hcs_ph_mwo_desc',
        needsVerification: true,
      ),
    ],
    beforeYouSign: BeforeYouSignChecklistDef(
      maxFeeRuleKey: 'eosb_bys_ph_fee',
      maxFeeNeedsVerification: true,
      redFlagKeys: [
        'eosb_bys_ph_flag_pay_before_contract',
        'eosb_bys_ph_flag_unlicensed_agency',
        'eosb_bys_ph_flag_no_dmw_contract',
        'eosb_bys_ph_flag_salary_mismatch',
      ],
      originVerificationChannels: [
        HomeCountrySupportResourceDef(
          id: 'dmw_agency_lookup',
          titleKey: 'eosb_bys_ph_dmw_link_title',
          descriptionKey: 'eosb_bys_ph_dmw_link_desc',
          url: 'https://www.dmw.gov.ph',
          needsVerification: true,
        ),
      ],
    ),
  );

  /// Welcome Home returnee pathways — verified URLs from Step 0 audit (2026-10-16).
  static const returnSupportLastVerifiedIso = '2026-10-16';

  static const philippinesReturnSupport = ReturnSupportBundleDef(
    state: ReturnSupportState.available,
    authorityNameKey: 'wh_ph_authority',
    requirementsNoteKey: 'wh_requirements_note',
    recheckNoteKey: 'wh_recheck_note',
    lastVerifiedIso: returnSupportLastVerifiedIso,
    preReturnPortalNoteKey: 'wh_ph_pre_return_note',
    hotlines: [
      ReturnSupportHotlineDef(
        labelKey: 'wh_hotline_label',
        number: '1348',
        dialUri: 'tel:1348',
      ),
      ReturnSupportHotlineDef(
        labelKey: 'wh_hotline_overseas_label',
        number: '+63 2 1348',
        dialUri: 'tel:+6321348',
      ),
    ],
    programs: [
      ReturnSupportProgramDef(
        id: 'owwa_reintegration_portal',
        nameKey: 'wh_ph_program_portal_name',
        summaryKey: 'wh_ph_program_portal_summary',
        officialUrl: 'https://reintegration.owwa.gov.ph/',
        urlVerifiedIso: returnSupportLastVerifiedIso,
      ),
      ReturnSupportProgramDef(
        id: 'owwa_reintegration_overview',
        nameKey: 'wh_ph_program_overview_name',
        summaryKey: 'wh_ph_program_overview_summary',
        officialUrl: 'https://owwa.gov.ph/reintegration/',
        urlVerifiedIso: returnSupportLastVerifiedIso,
      ),
    ],
  );

  static const nepalReturnSupport = ReturnSupportBundleDef(
    state: ReturnSupportState.available,
    authorityNameKey: 'wh_np_authority',
    requirementsNoteKey: 'wh_requirements_note',
    recheckNoteKey: 'wh_recheck_note',
    lastVerifiedIso: returnSupportLastVerifiedIso,
    hotlines: [
      ReturnSupportHotlineDef(
        labelKey: 'wh_np_hotline_label',
        number: '16600150005',
        dialUri: 'tel:16600150005',
      ),
      ReturnSupportHotlineDef(
        labelKey: 'wh_np_hotline_alt_label',
        number: '1141',
        dialUri: 'tel:1141',
      ),
    ],
    programs: [
      ReturnSupportProgramDef(
        id: 'feb_reintegration_framework',
        nameKey: 'wh_np_program_feb_name',
        summaryKey: 'wh_np_program_feb_summary',
        officialUrl: 'https://feb.gov.np/',
        urlVerifiedIso: returnSupportLastVerifiedIso,
      ),
    ],
  );

  static const keralaReturnSupport = ReturnSupportBundleDef(
    state: ReturnSupportState.available,
    authorityNameKey: 'wh_kl_authority',
    requirementsNoteKey: 'wh_requirements_note',
    recheckNoteKey: 'wh_recheck_note',
    lastVerifiedIso: returnSupportLastVerifiedIso,
    programs: [
      ReturnSupportProgramDef(
        id: 'norka_santhwana',
        nameKey: 'wh_kl_program_santhwana_name',
        summaryKey: 'wh_kl_program_santhwana_summary',
        officialUrl: 'https://www.santhwana.norkaroots.kerala.gov.in/',
        urlVerifiedIso: returnSupportLastVerifiedIso,
      ),
      ReturnSupportProgramDef(
        id: 'norka_ndprem',
        nameKey: 'wh_kl_program_ndprem_name',
        summaryKey: 'wh_kl_program_ndprem_summary',
        officialUrl: 'https://ndprem.norkaroots.kerala.gov.in/',
        urlVerifiedIso: returnSupportLastVerifiedIso,
      ),
    ],
  );

  static const indiaNationalUnavailableBundle = ReturnSupportBundleDef(
    state: ReturnSupportState.notAvailable,
    authorityNameKey: 'wh_in_unavailable_authority',
    requirementsNoteKey: 'wh_requirements_note',
    recheckNoteKey: 'wh_recheck_note',
    lastVerifiedIso: returnSupportLastVerifiedIso,
    programs: [],
  );

  static const genericUnavailableBundle = ReturnSupportBundleDef(
    state: ReturnSupportState.notAvailable,
    authorityNameKey: 'wh_generic_unavailable_authority',
    requirementsNoteKey: 'wh_requirements_note',
    recheckNoteKey: 'wh_recheck_note',
    lastVerifiedIso: returnSupportLastVerifiedIso,
    programs: [],
  );

  static const indiaConsularFallbacks = [
    ReturnSupportFallbackLinkDef(
      id: 'madad',
      titleKey: 'wh_fallback_madad_title',
      descriptionKey: 'wh_fallback_madad_desc',
      url: 'https://madad.gov.in',
    ),
    ReturnSupportFallbackLinkDef(
      id: 'india_embassy_labour',
      titleKey: 'eosb_hcs_india_embassy_title',
      descriptionKey: 'wh_fallback_embassy_labour_desc',
      phone: '+97444255714',
    ),
  ];
}

/// Back-compat alias — both features read [MigrantSupportCatalog].
typedef HomeCountrySupportCatalog = MigrantSupportCatalog;
