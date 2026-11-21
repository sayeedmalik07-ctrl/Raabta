import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Shared MOCI consumer-protection reference copy (Law No. 8 of 2008).
abstract final class ConsumerProtectionStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'cp_screen_title': l10nEntry(
      english: 'How to File a Consumer Complaint',
      arabic: 'كيفية تقديم شكوى استهلاكية',
      hindi: 'Consumer complaint kaise file karein',
      urdu: 'Consumer complaint kaise file karein',
    ),
    'cp_card_title': l10nEntry(
      english: 'MOCI consumer complaint — general products & services',
      arabic: 'شكوى استهلاكية MOCI — منتجات وخدمات عامة',
      hindi: 'MOCI consumer complaint — general products & services',
      urdu: 'MOCI consumer complaint — general products & services',
    ),
    'cp_card_intro': l10nEntry(
      english:
          'Under Law No. 8 of 2008, the Ministry of Commerce and Industry (MOCI) Consumer Protection and Combating Commercial Fraud Department handles complaints about products, services, fraud, and unfair business practices — when no more specific regulator applies.',
      arabic:
          'بموجب القانون رقم 8 لسنة 2008، قسم حماية المستهلك ومكافحة الغش التجاري في MOCI يتعامل مع شكاوى المنتجات والخدمات والاحتيال — عندما لا ينطبق منظم قطاعي أكثر تحديداً.',
      hindi:
          'Law No. 8 of 2008 ke under MOCI Consumer Protection Department products/services/fraud complaints handle karta hai — jab koi specific sector regulator apply na ho.',
      urdu:
          'Law No. 8 of 2008 ke under MOCI Consumer Protection Department products/services/fraud complaints handle karta hai — jab koi specific sector regulator apply na ho.',
    ),
    'cp_regulators_note': l10nEntry(
      english:
          'Other channels exist for sector-specific disputes — do not misdirect: telecom complaints escalate to CRA after your provider; banking issues to QCB; health insurance to MoPH. Use MOCI for general consumer/product/service disputes.',
      arabic:
          'قنوات أخرى للقطاعات: telecom → CRA، banking → QCB، health insurance → MoPH. استخدم MOCI للنزاعات الاستهلاكية العامة.',
      hindi:
          'Sector-specific: telecom → CRA (provider ke baad), banking → QCB, health insurance → MoPH. General consumer disputes → MOCI.',
      urdu:
          'Sector-specific: telecom → CRA (provider ke baad), banking → QCB, health insurance → MoPH. General consumer disputes → MOCI.',
    ),
    'cp_invoice_required_title': l10nEntry(
      english: 'Original invoice or receipt required',
      arabic: 'الفاتورة أو الإيصال الأصلي مطلوب',
      hindi: 'Original invoice/receipt required',
      urdu: 'Original invoice/receipt required',
    ),
    'cp_invoice_required_body': l10nEntry(
      english:
          'MOCI cannot consider a complaint without the original invoice or receipt. Keep receipts for any significant purchase — photos or copies alone may not be enough.',
      arabic:
          'لا يمكن لـ MOCI النظر في الشكوى بدون الفاتورة أو الإيصال الأصلي. احتفظ بإيصالات أي purchase مهم.',
      hindi:
          'Bina original invoice/receipt ke MOCI complaint consider nahi kar sakta. Significant purchase ki receipts rakhein.',
      urdu:
          'Bina original invoice/receipt ke MOCI complaint consider nahi kar sakta. Significant purchase ki receipts rakhein.',
    ),
    'cp_channels': l10nEntry(
      english:
          'Confirmed channels: hotline 16001, email info@mec.gov.qa, @MEC_Qatar on social media, and the MEC_Qatar mobile app (Android/iOS).',
      arabic:
          'القنوات: 16001، info@mec.gov.qa، @MEC_Qatar، تطبيق MEC_Qatar.',
      hindi:
          'Channels: hotline 16001, info@mec.gov.qa, @MEC_Qatar, MEC_Qatar app.',
      urdu:
          'Channels: hotline 16001, info@mec.gov.qa, @MEC_Qatar, MEC_Qatar app.',
    ),
    'cp_enforcement': l10nEntry(
      english:
          'MOCI has real enforcement backing: inspection officers have investigative authority, and the ministry can fine, close, or otherwise penalize violating businesses. A published MOCI case compelled a car dealer to replace a defective vehicle with a new one after a consumer complaint.',
      arabic:
          'لـ MOCI سلطة تنفيذية: ضباط تفتيش، غرامات وإغلاق. case منشور: MOCI ألزم dealer باستبدال سيارة معيبة بسيارة جديدة بعد شكوى مستهلك.',
      hindi:
          'MOCI ke paas enforcement power hai — fines, closure. Published case: dealer ko defective car replace karne par majboor kiya gaya.',
      urdu:
          'MOCI ke paas enforcement power hai — fines, closure. Published case: dealer ko defective car replace karne par majboor kiya gaya.',
    ),
    'cp_telecom_context_note': l10nEntry(
      english:
          'For telecom contract disputes, complain to your provider first, then escalate to CRA if eligible — see the telecom decoder below. MOCI below is for general consumer/product disputes.',
      arabic:
          'لنزاعات telecom: شكوى للمزود أولاً ثم CRA — انظر decoder أدناه. MOCI أدناه للنزاعات الاستهلاكية العامة.',
      hindi:
          'Telecom disputes: provider first, phir CRA — neeche telecom section dekhein. Neeche wala MOCI card general consumer ke liye hai.',
      urdu:
          'Telecom disputes: provider first, phir CRA — neeche telecom section dekhein. Neeche wala MOCI card general consumer ke liye hai.',
    ),
  };
}
