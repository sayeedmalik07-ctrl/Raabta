import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class WelcomeHomeStrings {
  static const keysNeedingReview = {
    'wh_ph_program_portal_summary',
    'wh_ph_program_overview_summary',
    'wh_np_program_feb_summary',
    'wh_kl_program_santhwana_summary',
    'wh_kl_program_ndprem_summary',
    'wh_ph_pre_return_note',
    'wh_requirements_note',
  };

  static String t(String key, String locale) {
    final row = _catalog[key];
    if (row == null) return key;
    return row[locale] ?? row['English'] ?? key;
  }

  static String tf(String key, String locale, Map<String, String> params) {
    var text = t(key, locale);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  static final _catalog = <String, Map<String, String>>{
    'wh_lq_card_title': l10nEntry(
      english: 'Going home? Support waiting for you',
      arabic: 'العودة للوطن؟ دعم ينتظرك',
    ),
    'wh_lq_card_body': l10nEntry(
      english:
          'Official returnee pathways for your nationality — link-out only. Raabta does not process applications or confirm eligibility.',
      arabic:
          'مسارات رسمية للعائدين حسب جنسيتك — روابط خارجية فقط. Raabta لا تقدم طلبات ولا تؤكد الأهلية.',
    ),
    'wh_lq_card_action': l10nEntry(
      english: 'Open Welcome Home guide',
      arabic: 'فتح دليل العودة',
    ),
    'wh_screen_title': l10nEntry(
      english: 'Welcome Home',
      arabic: 'العودة للوطن',
    ),
    'wh_screen_intro': l10nEntry(
      english:
          'Raabta routes you to official channels only. Confirm programme requirements, membership, and documents with the authority — we do not guarantee assistance.',
      arabic:
          'Raabta توجهك إلى القنوات الرسمية فقط. تحقق من المتطلبات والعضوية والمستندات لدى الجهة — لا نضمن الحصول على assistance.',
    ),
    'wh_needs_internet': l10nEntry(
      english: 'Needs internet',
      arabic: 'يتطلب اتصالاً',
    ),
    'wh_last_verified': l10nEntry(
      english: 'Last verified {date}',
      arabic: 'آخر تحقق {date}',
    ),
    'wh_recheck_note': l10nEntry(
      english: 'Recheck official sources if schemes or contacts change.',
      arabic: 'أعد التحقق من المصادر الرسمية إذا تغيرت البرامج أو جهات الاتصال.',
    ),
    'wh_requirements_note': l10nEntry(
      english:
          'Programmes may ask for proof you worked abroad and have returned, active membership, or other documents — check each official channel.',
      arabic:
          'قد تطلب البرامج إثبات العمل abroad والعودة أو عضوية سارية أو مستندات أخرى — راجع كل قناة رسمية.',
    ),
    'wh_country_picker_heading': l10nEntry(
      english: 'Your nationality / home country',
      arabic: 'جنسيتك / بلدك',
    ),
    'wh_country_picker_hint': l10nEntry(
      english:
          'We use your profile when available. Choose a country below to preview official pathways (not saved to your account).',
      arabic:
          'نستخدم ملفك عند توفره. اختر بلداً below لمعاينة المسارات الرسمية (لا يُحفظ في حسابك).',
    ),
    'wh_unavailable_title': l10nEntry(
      english: 'No confirmed national returnee programme yet',
      arabic: 'لا برنامج وطني مؤكد للعائدين بعد',
    ),
    'wh_unavailable_body': l10nEntry(
      english:
          'We have not verified a unified official returnee programme for your case. Your embassy or consular welfare desk can explain what exists.',
      arabic:
          'لم نتحقق من برنامج وطني موحد للعائدين لحالتك. السفارة أو قسم رعاية المواطنين يمكن أن يوضح ما هو متاح.',
    ),
    'wh_open_official_site': l10nEntry(
      english: 'Open official site',
      arabic: 'فتح الموقع الرسمي',
    ),
    'wh_scam_caution': l10nEntry(
      english:
          'Check the official channel before paying anyone to "process" a grant or loan.',
      arabic:
          'تحقق من القناة الرسمية قبل دفع أي شخص لـ"معالجة" منحة أو قرض.',
    ),
    'wh_scam_link': l10nEntry(
      english: 'ScamShield',
      arabic: 'ScamShield',
    ),
    'wh_checklist_heading': l10nEntry(
      english: 'Before you fly home',
      arabic: 'قبل السفر إلى الوطن',
    ),
    'wh_checklist_note': l10nEntry(
      english: 'Local checklist only — not sent to Raabta servers.',
      arabic: 'قائمة محلية فقط — لا تُرسل إلى خوادم Raabta.',
    ),
    'wh_ph_authority': l10nEntry(
      english: 'Overseas Workers Welfare Administration (OWWA)',
      arabic: 'OWWA',
    ),
    'wh_ph_pre_return_note': l10nEntry(
      english:
          'You may start online registration on the official OWWA reintegration portal before you travel — confirm membership and requirements with OWWA/DMW.',
      arabic:
          'يمكنك بدء التسجيل online على بوابة OWWA الرسمية قبل السفر — تحقق من العضوية والمتطلبات لدى OWWA/DMW.',
    ),
    'wh_ph_program_portal_name': l10nEntry(
      english: 'OWWA reintegration portal',
      arabic: 'بوابة OWWA للإدماج',
    ),
    'wh_ph_program_portal_summary': l10nEntry(
      english:
          'Official online intake for returning OFWs — profiling, pathway selection, and referrals to training or employment partners.',
      arabic:
          'استقبال online رسمي للOFW العائدين — profiling واختيار مسار وإحالات للتدريب أو التوظيف.',
    ),
    'wh_ph_program_overview_name': l10nEntry(
      english: 'OWWA reintegration programme overview',
      arabic: 'نظرة على برنامج إدماج OWWA',
    ),
    'wh_ph_program_overview_summary': l10nEntry(
      english:
          'Government overview of psycho-social and economic reintegration services for OFWs and families.',
      arabic: 'نظرة حكومية على خدمات الإدماج psycho-social والاقتصادي للOFW والعائلات.',
    ),
    'wh_hotline_label': l10nEntry(
      english: 'OWWA / DMW hotline (Philippines)',
      arabic: 'خط OWWA / DMW (الفلبين)',
    ),
    'wh_hotline_overseas_label': l10nEntry(
      english: 'OWWA hotline from overseas',
      arabic: 'خط OWWA من abroad',
    ),
    'wh_np_authority': l10nEntry(
      english: 'Foreign Employment Board, Nepal',
      arabic: 'Foreign Employment Board, Nepal',
    ),
    'wh_np_program_feb_name': l10nEntry(
      english: 'FEB reintegration via Employment Service Centre',
      arabic: 'FEB reintegration via Employment Service Centre',
    ),
    'wh_np_program_feb_summary': l10nEntry(
      english:
          'Returnees apply through their local municipal Employment Service Centre under FEB reintegration directives — not via a separate ReMi desk.',
      arabic:
          'Returnees apply through their local municipal Employment Service Centre under FEB reintegration directives.',
    ),
    'wh_np_hotline_label': l10nEntry(
      english: 'FEB Shram call center',
      arabic: 'FEB Shram call center',
    ),
    'wh_np_hotline_alt_label': l10nEntry(
      english: 'FEB Shram call center (alt)',
      arabic: 'FEB Shram call center (alt)',
    ),
    'wh_kl_authority': l10nEntry(
      english: 'NORKA Roots, Government of Kerala',
      arabic: 'NORKA Roots, Government of Kerala',
    ),
    'wh_kl_program_santhwana_name': l10nEntry(
      english: 'Santhwana scheme portal',
      arabic: 'Santhwana scheme portal',
    ),
    'wh_kl_program_santhwana_summary': l10nEntry(
      english:
          'Kerala state distress-relief portal for returned NRKs — apply and confirm eligibility on the official site.',
      arabic:
          'Kerala state distress-relief portal for returned NRKs — apply on the official site.',
    ),
    'wh_kl_program_ndprem_name': l10nEntry(
      english: 'NDPREM scheme portal',
      arabic: 'NDPREM scheme portal',
    ),
    'wh_kl_program_ndprem_summary': l10nEntry(
      english:
          'Kerala Department project for returned emigrants — register and follow official application steps online.',
      arabic:
          'Kerala Department project for returned emigrants — register online via official portal.',
    ),
    'wh_in_unavailable_authority': l10nEntry(
      english: 'Government of India (state-level programmes)',
      arabic: 'Government of India (state-level programmes)',
    ),
    'wh_generic_unavailable_authority': l10nEntry(
      english: 'Your home country authorities',
      arabic: 'Your home country authorities',
    ),
    'wh_consular_resources_heading': l10nEntry(
      english: 'Verified consular resources',
      arabic: 'موارد قنصلية verified',
    ),
    'wh_fallback_madad_title': l10nEntry(
      english: 'MADAD consular portal',
      arabic: 'MADAD consular portal',
    ),
    'wh_fallback_madad_desc': l10nEntry(
      english: 'Consular grievance and welfare routing — not a returnee benefits application.',
      arabic: 'Consular grievance routing — not a returnee benefits application.',
    ),
    'wh_fallback_embassy_labour_desc': l10nEntry(
      english: 'Indian Embassy labour section in Doha — ask about welfare and return guidance.',
      arabic: 'Indian Embassy labour section in Doha.',
    ),
    'wh_fallback_embassy_desc': l10nEntry(
      english: 'Verified consular portal link — ask the welfare section what returnee help exists.',
      arabic: 'Verified consular portal — ask welfare section.',
    ),
    'wh_fallback_embassy_india_title': l10nEntry(
      english: 'India MADAD / consular',
      arabic: 'India MADAD / consular',
    ),
    'wh_fallback_embassy_nepal_title': l10nEntry(
      english: 'Nepal consular services',
      arabic: 'Nepal consular services',
    ),
    'wh_fallback_embassy_ph_title': l10nEntry(
      english: 'Philippines DMW portal',
      arabic: 'Philippines DMW portal',
    ),
    'wh_fallback_embassy_generic_title': l10nEntry(
      english: 'Consular portal',
      arabic: 'Consular portal',
    ),
    'wh_eosb_link': l10nEntry(
      english: 'Returnee support after you leave',
      arabic: 'Returnee support after you leave',
    ),
    'wh_check_experience_certificate': l10nEntry(
      english: 'Ask your employer for an experience certificate',
      arabic: 'Ask your employer for an experience certificate',
    ),
    'wh_check_contract_settlement': l10nEntry(
      english: 'Keep contract, salary slips, and final settlement papers',
      arabic: 'Keep contract, salary slips, and final settlement papers',
    ),
    'wh_check_rp_passport': l10nEntry(
      english:
          'Keep RP cancellation confirmation and passport stamps — some programmes ask for proof of work abroad and return',
      arabic:
          'Keep RP cancellation confirmation and passport stamps',
    ),
    'wh_check_vault': l10nEntry(
      english: 'Save copies in Document Vault (available offline)',
      arabic: 'Save copies in Document Vault',
    ),
    'wh_check_eosb': l10nEntry(
      english: 'Know what you are owed — review your EOSB estimate',
      arabic: 'Know what you are owed — review EOSB',
    ),
    'wh_check_health': l10nEntry(
      english: 'Plan health coverage after employer insurance ends',
      arabic: 'Plan health coverage after employer insurance ends',
    ),
  };

  static String checklistLabel(String itemId, String locale) {
    return switch (itemId) {
      'experience_certificate' => t('wh_check_experience_certificate', locale),
      'contract_settlement_papers' => t('wh_check_contract_settlement', locale),
      'rp_cancellation_passport' => t('wh_check_rp_passport', locale),
      'document_vault_copies' => t('wh_check_vault', locale),
      'eosb_entitlement' => t('wh_check_eosb', locale),
      'health_coverage_gap' => t('wh_check_health', locale),
      _ => itemId,
    };
  }
}
