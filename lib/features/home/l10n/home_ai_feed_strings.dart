import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Static templates for [AIFeedEngine] cards — data fields stay interpolated.
abstract final class HomeAiFeedStrings {
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
    'feed_job_title': l10nEntry(
      english: '💼 {count} jobs match your profile',
      arabic: '💼 {count} وظائف تناسب ملفك',
      hindi: '💼 {count} jobs match your profile',
      urdu: '💼 {count} jobs match your profile',
    ),
    'feed_job_subtitle': l10nEntry(
      english: 'Best: {title} at {company} — {match}% match',
      arabic: 'الأفضل: {title} في {company} — تطابق {match}%',
      hindi: 'Best: {title} at {company} — {match}% match',
      urdu: 'Best: {title} at {company} — {match}% match',
    ),
    'feed_job_cta': l10nEntry(
      english: 'View Jobs',
      arabic: 'عرض الوظائف',
      hindi: 'View Jobs',
      urdu: 'View Jobs',
    ),
    'feed_job_fallback_title': l10nEntry(
      english: 'Recommended role',
      arabic: 'دور موصى به',
    ),
    'feed_job_fallback_company': l10nEntry(
      english: 'Qatar employer',
      arabic: 'صاحب عمل في قطر',
    ),
    'feed_housing_title': l10nEntry(
      english: '🏠 {count} new rooms in {area}',
      arabic: '🏠 {count} غرف جديدة في {area}',
    ),
    'feed_housing_subtitle': l10nEntry(
      english: 'Best match: {type} at {price} QR/month — {match}%',
      arabic: 'أفضل تطابق: {type} بـ {price} ر.ق/شهر — {match}%',
    ),
    'feed_housing_cta': l10nEntry(
      english: 'View Housing',
      arabic: 'عرض السكن',
    ),
    'feed_property_fallback': l10nEntry(
      english: 'Property',
      arabic: 'عقار',
    ),
    'feed_exchange_title_up': l10nEntry(
      english: '💰 INR rate increased today',
      arabic: '💰 ارتفع سعر الروبية الهندية اليوم',
    ),
    'feed_exchange_title_down': l10nEntry(
      english: '💰 INR rate decreased today',
      arabic: '💰 انخفض سعر الروبية الهندية اليوم',
    ),
    'feed_exchange_subtitle': l10nEntry(
      english: '1 QR = {rate} INR {arrow}{change}',
      arabic: '1 ر.ق = {rate} INR {arrow}{change}',
    ),
    'feed_exchange_cta': l10nEntry(
      english: 'Check Rates',
      arabic: 'تحقق من الأسعار',
    ),
    'feed_visa_title': l10nEntry(
      english: '📋 New Qatar visa update',
      arabic: '📋 تحديث جديد لتأشيرة قطر',
    ),
    'feed_visa_subtitle': l10nEntry(
      english: '{title} — {date}',
      arabic: '{title} — {date}',
    ),
    'feed_visa_cta': l10nEntry(
      english: 'Read Update',
      arabic: 'قراءة التحديث',
    ),
    'feed_visa_fallback': l10nEntry(
      english: 'Visa policy update',
      arabic: 'تحديث سياسة التأشيرة',
    ),
    'feed_event_title': l10nEntry(
      english: '🎉 {name} this {day}',
      arabic: '🎉 {name} {day}',
    ),
    'feed_event_subtitle': l10nEntry(
      english: '{location} · {community} Community · {price}',
      arabic: '{location} · مجتمع {community} · {price}',
    ),
    'feed_event_cta': l10nEntry(
      english: 'Join Event',
      arabic: 'انضم إلى الفعالية',
    ),
    'feed_event_fallback_name': l10nEntry(
      english: 'Community event',
      arabic: 'فعالية مجتمعية',
    ),
    'feed_price_free': l10nEntry(
      english: 'Free',
      arabic: 'مجاني',
    ),
    'feed_day_today': l10nEntry(
      english: 'today',
      arabic: 'اليوم',
    ),
    'feed_day_tomorrow': l10nEntry(
      english: 'tomorrow',
      arabic: 'غداً',
    ),
    'feed_day_week': l10nEntry(
      english: 'week',
      arabic: 'هذا الأسبوع',
    ),
    'feed_score_title': l10nEntry(
      english: '⭐ Improve your Expat Score by +{points} points',
      arabic: '⭐ حسّن درجة Expat Score بـ +{points} نقطة',
    ),
    'feed_referral_title': l10nEntry(
      english: '👥 Invite friends, earn 50 points each',
      arabic: '👥 ادعُ الأصدقاء واكسب 50 نقطة لكل دعوة',
    ),
    'feed_referral_sub_premium': l10nEntry(
      english:
          "You've invited {count} friends. {remaining} more to unlock Premium free!",
      arabic:
          'دعوت {count} أصدقاء. {remaining} إضافيين لفتح Premium مجاناً!',
    ),
    'feed_referral_sub_boost': l10nEntry(
      english:
          "You've invited {count} friends. When they complete EOSB, you both get +{extra} extra AI questions/day for {days} days.",
      arabic:
          'دعوت {count} أصدقاء. عند إكمال EOSB، تحصلان على +{extra} أسئلة AI إضافية/يوم لمدة {days} يوم.',
    ),
    'feed_referral_cta': l10nEntry(
      english: 'Share Raabta',
      arabic: 'شارك Raabta',
    ),
    'feed_welcome_title': l10nEntry(
      english: '👋 Welcome back to Raabta',
      arabic: '👋 مرحباً بعودتك إلى Raabta',
    ),
    'feed_welcome_subtitle': l10nEntry(
      english: 'Your personalized Qatar expat feed is ready',
      arabic: 'خلاصتك المخصصة للمغتربين في قطر جاهزة',
    ),
    'feed_welcome_cta': l10nEntry(
      english: 'Explore',
      arabic: 'استكشف',
    ),
    'feed_business_fallback_title': l10nEntry(
      english: '🏪 Business offer near you',
      arabic: '🏪 عرض تجاري قريب منك',
    ),
    'feed_business_cta': l10nEntry(
      english: 'View Offer',
      arabic: 'عرض العرض',
    ),
    'feed_gov_fallback_title': l10nEntry(
      english: '🏛️ Government announcement',
      arabic: '🏛️ إعلان حكومي',
    ),
    'feed_learn_more': l10nEntry(
      english: 'Learn More',
      arabic: 'اعرف المزيد',
    ),
    'feed_sponsored_fallback': l10nEntry(
      english: 'Sponsored',
      arabic: 'برعاية',
    ),
    'feed_sponsor_label': l10nEntry(
      english: 'SPONSORED',
      arabic: 'برعاية',
    ),
    'feed_cache_relative': l10nEntry(
      english: 'Last updated {time}',
      arabic: 'آخر تحديث {time}',
    ),
    'feed_offline_note': l10nEntry(
      english: 'Showing offline welcome feed',
      arabic: 'عرض خلاصة ترحيب دون اتصال',
    ),
    'feed_date_recently': l10nEntry(
      english: 'Recently',
      arabic: 'مؤخراً',
    ),
    'feed_relative_minutes': l10nEntry(
      english: '{count}m ago',
      arabic: 'منذ {count} د',
    ),
    'feed_relative_hours': l10nEntry(
      english: '{count}h ago',
      arabic: 'منذ {count} س',
    ),
    'feed_relative_days': l10nEntry(
      english: '{count}d ago',
      arabic: 'منذ {count} ي',
    ),
    'for_you_because_job_match': l10nEntry(
      english: 'Because your profile matches roles at {match}%',
      arabic: 'لأن ملفك يطابق وظائف بنسبة {match}%',
    ),
    'for_you_because_job_profession': l10nEntry(
      english: 'Because you work as {profession}',
      arabic: 'لأن مهنتك {profession}',
    ),
    'for_you_because_housing_area': l10nEntry(
      english: 'Because you set {area} as your area',
      arabic: 'لأنك اخترت {area} كمنطقتك',
    ),
    'for_you_because_housing_match': l10nEntry(
      english: 'Because listings match your search at {match}%',
      arabic: 'لأن العروض تطابق بحثك بنسبة {match}%',
    ),
    'for_you_because_exchange_up': l10nEntry(
      english: 'Because INR moved up against QAR today',
      arabic: 'لأن الروبية الهندية ارتفعت مقابل الريال اليوم',
    ),
    'for_you_because_exchange_down': l10nEntry(
      english: 'Because INR moved down against QAR today',
      arabic: 'لأن الروبية الهندية انخفضت مقابل الريال اليوم',
    ),
    'for_you_because_exchange_rates': l10nEntry(
      english: 'Because QAR exchange rates updated',
      arabic: 'لأن أسعار صرف الريال تحدّثت',
    ),
    'for_you_because_visa_update': l10nEntry(
      english: 'Because there is a recent visa update',
      arabic: 'لأن هناك تحديثاً حديثاً للتأشيرة',
    ),
    'for_you_because_event_area': l10nEntry(
      english: 'Because events are listed near {area}',
      arabic: 'لأن هناك فعاليات قرب {area}',
    ),
    'for_you_because_event_week': l10nEntry(
      english: 'Because community events are coming up this week',
      arabic: 'لأن فعاليات مجتمعية هذا الأسبوع',
    ),
  };
}
