/// Scam Shield Academy — educational checkpoint copy (9 locales).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

abstract final class ScamShieldAcademyStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static const keysNeedingProfessionalReview = <String>{
    'ss_academy_stage_contact_title',
    'ss_academy_stage_contact_explain',
    'ss_academy_stage_contact_example',
    'ss_academy_stage_contact_why',
    'ss_academy_stage_impersonation_title',
    'ss_academy_stage_impersonation_explain',
    'ss_academy_stage_impersonation_example',
    'ss_academy_stage_impersonation_why',
    'ss_academy_stage_informationHarvesting_title',
    'ss_academy_stage_informationHarvesting_explain',
    'ss_academy_stage_informationHarvesting_example',
    'ss_academy_stage_informationHarvesting_why',
    'ss_academy_stage_credentialHarvesting_title',
    'ss_academy_stage_credentialHarvesting_explain',
    'ss_academy_stage_credentialHarvesting_example',
    'ss_academy_stage_credentialHarvesting_why',
    'ss_academy_stage_otpHarvesting_title',
    'ss_academy_stage_otpHarvesting_explain',
    'ss_academy_stage_otpHarvesting_example',
    'ss_academy_stage_otpHarvesting_why',
    'ss_academy_stage_simSwapRisk_title',
    'ss_academy_stage_simSwapRisk_explain',
    'ss_academy_stage_simSwapRisk_example',
    'ss_academy_stage_simSwapRisk_why',
    'ss_academy_stage_accountTakeoverRisk_title',
    'ss_academy_stage_accountTakeoverRisk_explain',
    'ss_academy_stage_accountTakeoverRisk_example',
    'ss_academy_stage_accountTakeoverRisk_why',
    'ss_academy_stage_financialAction_title',
    'ss_academy_stage_financialAction_explain',
    'ss_academy_stage_financialAction_example',
    'ss_academy_stage_financialAction_why',
    'ss_academy_stage_suspectedCompromise_title',
    'ss_academy_stage_suspectedCompromise_explain',
    'ss_academy_stage_suspectedCompromise_example',
    'ss_academy_stage_suspectedCompromise_why',
    'ss_academy_stage_incidentResponse_title',
    'ss_academy_stage_incidentResponse_explain',
    'ss_academy_stage_incidentResponse_example',
    'ss_academy_stage_incidentResponse_why',
    'ss_academy_actions_body',
  };

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale, {
    required Map<String, String> params,
  }) {
    var value = t(key, locale);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }

  static String stageTitle(ScamAttackStage stage, String locale) =>
      t('ss_academy_stage_${stage.name}_title', locale);

  static String stageExplain(ScamAttackStage stage, String locale) =>
      t('ss_academy_stage_${stage.name}_explain', locale);

  static String stageExample(ScamAttackStage stage, String locale) =>
      t('ss_academy_stage_${stage.name}_example', locale);

  static String stageWhy(ScamAttackStage stage, String locale) =>
      t('ss_academy_stage_${stage.name}_why', locale);

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'ss_academy_title': l10nEntry(
      english: 'Scam Shield Academy',
    ),
    'ss_academy_subtitle': l10nEntry(
      english: 'Short, fictional examples only — not legal advice. Learn common attack stages used in Qatar.',
    ),
    'ss_academy_home_entry_title': l10nEntry(
      english: 'Scam Shield Academy',
    ),
    'ss_academy_home_entry_sub': l10nEntry(
      english: 'Learn how scams escalate — optional 2-minute walkthrough',
    ),
    'ss_academy_progress': l10nEntry(
      english: '{current} of {total}',
    ),
    'ss_academy_why_label': l10nEntry(
      english: 'Why this matters',
    ),
    'ss_academy_example_label': l10nEntry(
      english: 'Fictional example',
    ),
    'ss_academy_mark_read': l10nEntry(
      english: 'Mark as read',
    ),
    'ss_academy_impersonation_heading': l10nEntry(
      english: 'Common impersonation types',
    ),
    'ss_academy_actions_title': l10nEntry(
      english: 'Take verified action',
    ),
    'ss_academy_actions_body': l10nEntry(
      english: 'If something matches these stages, use Raabta tools — not links in the message.',
    ),
    'ss_academy_open_incident': l10nEntry(
      english: 'Open incident reporter',
    ),
    'ss_academy_open_directory': l10nEntry(
      english: 'Open Safe Verification directory',
    ),
    'ss_academy_stage_contact_title': l10nEntry(
      english: 'Unexpected contact',
    ),
    'ss_academy_stage_contact_explain': l10nEntry(
      english: 'Scammers often start with an unsolicited call, SMS, WhatsApp, email, or social message. The tone may be friendly, urgent, or official.',
    ),
    'ss_academy_stage_contact_example': l10nEntry(
      english: 'Fictional: "Your package is on hold — reply YES to confirm delivery."',
    ),
    'ss_academy_stage_contact_why': l10nEntry(
      english: 'Recognising first contact helps you pause before sharing anything.',
    ),
    'ss_academy_stage_impersonation_title': l10nEntry(
      english: 'Fake authority',
    ),
    'ss_academy_stage_impersonation_explain': l10nEntry(
      english: 'They may claim to be government, a bank, telecom, delivery, or your employer. Real offices rarely demand secrets on first contact.',
    ),
    'ss_academy_stage_impersonation_example': l10nEntry(
      english: 'Fictional: "This is the fraud desk — we detected suspicious activity on your account."',
    ),
    'ss_academy_stage_impersonation_why': l10nEntry(
      english: 'Impersonation is designed to bypass your normal caution.',
    ),
    'ss_academy_stage_informationHarvesting_title': l10nEntry(
      english: 'Personal details requested',
    ),
    'ss_academy_stage_informationHarvesting_explain': l10nEntry(
      english: 'They ask for QID, passport, date of birth, address, or employment details — often framed as "verification".',
    ),
    'ss_academy_stage_informationHarvesting_example': l10nEntry(
      english: 'Fictional: "Send your QID number and DOB to unblock Metrash access."',
    ),
    'ss_academy_stage_informationHarvesting_why': l10nEntry(
      english: 'Identity details can be reused for fraud or account recovery attacks.',
    ),
    'ss_academy_stage_credentialHarvesting_title': l10nEntry(
      english: 'Passwords and logins',
    ),
    'ss_academy_stage_credentialHarvesting_explain': l10nEntry(
      english: 'Links to fake login pages or direct requests for banking passwords, PINs, or card numbers.',
    ),
    'ss_academy_stage_credentialHarvesting_example': l10nEntry(
      english: 'Fictional: "Sign in here to secure your online banking within 10 minutes."',
    ),
    'ss_academy_stage_credentialHarvesting_why': l10nEntry(
      english: 'Credentials give direct access to your money and accounts.',
    ),
    'ss_academy_stage_otpHarvesting_title': l10nEntry(
      english: 'One-time codes',
    ),
    'ss_academy_stage_otpHarvesting_explain': l10nEntry(
      english: 'They ask you to read aloud or forward SMS OTP codes — sometimes while pretending to "help" you.',
    ),
    'ss_academy_stage_otpHarvesting_example': l10nEntry(
      english: 'Fictional: "Tell me the 6-digit code we just sent — it expires in 2 minutes."',
    ),
    'ss_academy_stage_otpHarvesting_why': l10nEntry(
      english: 'OTP codes are often the last step before money moves or accounts change.',
    ),
    'ss_academy_stage_simSwapRisk_title': l10nEntry(
      english: 'SIM or eSIM risk',
    ),
    'ss_academy_stage_simSwapRisk_explain': l10nEntry(
      english: 'Pressure to approve a SIM change, share ICCID, or "upgrade" your line can enable number takeover.',
    ),
    'ss_academy_stage_simSwapRisk_example': l10nEntry(
      english: 'Fictional: "We are moving your number to a secure SIM — confirm the code on your screen."',
    ),
    'ss_academy_stage_simSwapRisk_why': l10nEntry(
      english: 'Controlling your phone number can reset passwords and bypass 2FA.',
    ),
    'ss_academy_stage_accountTakeoverRisk_title': l10nEntry(
      english: 'Account takeover',
    ),
    'ss_academy_stage_accountTakeoverRisk_explain': l10nEntry(
      english: 'Combined signals — shared details plus OTP or SIM change — suggest someone may already have access.',
    ),
    'ss_academy_stage_accountTakeoverRisk_example': l10nEntry(
      english: 'Fictional: "We changed your email for security — click to confirm it was you."',
    ),
    'ss_academy_stage_accountTakeoverRisk_why': l10nEntry(
      english: 'Early takeover response limits financial and identity damage.',
    ),
    'ss_academy_stage_financialAction_title': l10nEntry(
      english: 'Money movement',
    ),
    'ss_academy_stage_financialAction_explain': l10nEntry(
      english: 'Requests for transfers, gift cards, crypto, or fees to "release" funds, prizes, or visas.',
    ),
    'ss_academy_stage_financialAction_example': l10nEntry(
      english: 'Fictional: "Pay a QAR 500 clearance fee today via wire transfer to release your refund."',
    ),
    'ss_academy_stage_financialAction_why': l10nEntry(
      english: 'Money sent to scammers is very hard to recover.',
    ),
    'ss_academy_stage_suspectedCompromise_title': l10nEntry(
      english: 'Multiple warning signs',
    ),
    'ss_academy_stage_suspectedCompromise_explain': l10nEntry(
      english: 'When several stages appear together — impersonation, data shared, and urgency — treat it as active compromise.',
    ),
    'ss_academy_stage_suspectedCompromise_example': l10nEntry(
      english: 'Fictional: "You already shared QID and an OTP — complete the transfer to avoid legal action."',
    ),
    'ss_academy_stage_suspectedCompromise_why': l10nEntry(
      english: 'Compound patterns match how real Qatar-targeted scams escalate.',
    ),
    'ss_academy_stage_incidentResponse_title': l10nEntry(
      english: 'If you may be compromised',
    ),
    'ss_academy_stage_incidentResponse_explain': l10nEntry(
      english: 'Stop engaging, use official numbers from your card or government sites (not links in the message), and document what happened.',
    ),
    'ss_academy_stage_incidentResponse_example': l10nEntry(
      english: 'Fictional: "Do not reply — call your bank using the number on your card and check Metrash via the official app."',
    ),
    'ss_academy_stage_incidentResponse_why': l10nEntry(
      english: 'Fast, verified response reduces ongoing harm.',
    ),
  };
}
