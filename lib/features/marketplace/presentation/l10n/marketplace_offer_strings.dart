import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class MarketplaceOfferStrings {
  static const supportedLocales = AppLocale.supportedLocales;

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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'mp_make_offer': l10nEntry(
      english: 'Make Offer',
      arabic: 'قدّم عرضًا',
      hindi: 'Make Offer',
    ),
    'mp_make_offer_title': l10nEntry(
      english: 'Make a price offer',
      arabic: 'قدّم عرض سعر',
      hindi: 'Price offer karein',
    ),
    'mp_make_offer_subtitle': l10nEntry(
      english:
          'This is a price proposal between you and the seller — not a payment. Raabta does not process money for Marketplace listings.',
      arabic:
          'هذا عرض سعر بينك وبين البائع — وليس دفعة. رابطة لا تعالج المدفوعات في السوق.',
      hindi:
          'Yeh aap aur seller ke beech price proposal hai — payment nahi. Raabta Marketplace mein paise process nahi karta.',
    ),
    'mp_offer_amount_label': l10nEntry(
      english: 'Your offer (QAR)',
      arabic: 'عرضك (ريال)',
      hindi: 'Aapka offer (QAR)',
    ),
    'mp_offer_submit': l10nEntry(
      english: 'Submit offer',
      arabic: 'إرسال العرض',
      hindi: 'Offer submit karein',
    ),
    'mp_offer_invalid_amount': l10nEntry(
      english: 'Enter a valid offer amount.',
      arabic: 'أدخل مبلغ عرض صالحًا.',
      hindi: 'Valid offer amount enter karein.',
    ),
    'mp_offer_expires_note': l10nEntry(
      english: 'Offers expire after 24 hours if there is no response.',
      arabic: 'تنتهي العروض بعد 24 ساعة دون رد.',
      hindi: '24 ghante mein jawab na ho to offer expire ho jata hai.',
    ),
    'mp_offer_accepted_note': l10nEntry(
      english:
          'Accepted offers are a price agreement only — arrange pickup or delivery and payment directly with the seller outside Raabta.',
      arabic:
          'العروض المقبولة اتفاق على السعر فقط — رتّب الاستلام والدفع مباشرة مع البائع خارج رابطة.',
      hindi:
          'Accepted offer sirf price agreement hai — pickup/delivery aur payment seller ke saath directly karein.',
    ),
    'mp_seller_offers_heading': l10nEntry(
      english: 'Pending offers',
      arabic: 'العروض المعلّقة',
      hindi: 'Pending offers',
    ),
    'mp_seller_offers_count': l10nEntry(
      english: '{count} pending offer(s)',
      arabic: '{count} عرض/عروض معلّقة',
      hindi: '{count} pending offer(s)',
    ),
    'mp_offer_status_pending': l10nEntry(
      english: 'Awaiting your response',
      arabic: 'بانتظار ردك',
      hindi: 'Aapke response ka intezar',
    ),
    'mp_offer_status_awaiting_buyer': l10nEntry(
      english: 'Counter sent — awaiting buyer',
      arabic: 'تم إرسال counter — بانتظار المشتري',
      hindi: 'Counter bheja — buyer ka intezar',
    ),
    'mp_offer_status_yours_pending': l10nEntry(
      english: 'Your offer is pending',
      arabic: 'عرضك معلّق',
      hindi: 'Aapka offer pending hai',
    ),
    'mp_offer_status_counter_received': l10nEntry(
      english: 'Seller countered — respond below',
      arabic: 'رد البائع بعرض مضاد — رد أدناه',
      hindi: 'Seller ne counter diya — neeche respond karein',
    ),
    'mp_offer_action_accept': l10nEntry(
      english: 'Accept',
      arabic: 'قبول',
      hindi: 'Accept',
    ),
    'mp_offer_action_decline': l10nEntry(
      english: 'Decline',
      arabic: 'رفض',
      hindi: 'Decline',
    ),
    'mp_offer_action_counter': l10nEntry(
      english: 'Counter',
      arabic: 'عرض مضاد',
      hindi: 'Counter',
    ),
    'mp_offer_counter_title': l10nEntry(
      english: 'Counter-offer amount (QAR)',
      arabic: 'مبلغ العرض المضاد (ريال)',
      hindi: 'Counter-offer amount (QAR)',
    ),
    'mp_offer_line': l10nEntry(
      english: 'QAR {amount}',
      arabic: '{amount} ريال',
      hindi: 'QAR {amount}',
    ),
    'mp_offer_chat_accepted': l10nEntry(
      english:
          'Offer of QAR {amount} accepted — you can arrange pickup/delivery details here. This is not a payment through Raabta.',
      arabic:
          'تم قبول عرض {amount} ريال — يمكنك ترتيب التفاصيل هنا. هذا ليس دفعة عبر رابطة.',
      hindi:
          'QAR {amount} ka offer accept hua — yahan pickup/delivery details arrange karein. Yeh Raabta payment nahi hai.',
    ),
    'mp_offer_chat_declined': l10nEntry(
      english: 'Offer of QAR {amount} was declined.',
      arabic: 'تم رفض عرض {amount} ريال.',
      hindi: 'QAR {amount} ka offer decline hua.',
    ),
    'mp_offer_chat_countered': l10nEntry(
      english: 'Seller counter-offer: QAR {amount} — respond on the listing or here in chat.',
      arabic: 'عرض مضاد من البائع: {amount} ريال — رد في الإعلان أو هنا.',
      hindi: 'Seller counter: QAR {amount} — listing par ya yahan respond karein.',
    ),
    'mp_offer_notif_received_title': l10nEntry(
      english: 'New offer on your listing',
      arabic: 'عرض جديد على إعلانك',
      hindi: 'Aapki listing par naya offer',
    ),
    'mp_offer_notif_received_body': l10nEntry(
      english: '{title}: QAR {amount} offer received',
      arabic: '{title}: عرض {amount} ريال',
      hindi: '{title}: QAR {amount} offer mila',
    ),
    'mp_offer_notif_accepted_title': l10nEntry(
      english: 'Seller marked offer as accepted (off-platform)',
      arabic: 'تم قبول العرض',
      hindi: 'Offer accept hua',
    ),
    'mp_offer_notif_accepted_body': l10nEntry(
      english: '{title}: QAR {amount} agreed — arrange details in chat',
      arabic: '{title}: اتُفق على {amount} ريال — رتّب التفاصيل في المحادثة',
      hindi: '{title}: QAR {amount} agree — chat mein details arrange karein',
    ),
    'mp_offer_notif_declined_title': l10nEntry(
      english: 'Offer declined',
      arabic: 'تم رفض العرض',
      hindi: 'Offer decline hua',
    ),
    'mp_offer_notif_declined_body': l10nEntry(
      english: '{title}: QAR {amount} offer declined',
      arabic: '{title}: رُفض عرض {amount} ريال',
      hindi: '{title}: QAR {amount} offer decline',
    ),
    'mp_offer_notif_countered_title': l10nEntry(
      english: 'Counter-offer received',
      arabic: 'عرض مضاد وارد',
      hindi: 'Counter-offer mila',
    ),
    'mp_offer_notif_countered_body': l10nEntry(
      english: '{title}: seller countered at QAR {amount}',
      arabic: '{title}: عرض مضاد {amount} ريال',
      hindi: '{title}: seller ne QAR {amount} par counter diya',
    ),
  };
}
