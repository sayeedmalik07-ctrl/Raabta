import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Static templates for Expat Score improvement actions and hero advice on Home.
abstract final class HomeRecommendationStrings {
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
    'time_1_min': l10nEntry(english: '1 min', arabic: '1 د'),
    'time_1_tap': l10nEntry(english: '1 tap', arabic: 'نقرة واحدة'),
    'time_2_min': l10nEntry(english: '2 min', arabic: '2 د'),
    'time_3_min': l10nEntry(english: '3 min', arabic: '3 د'),
    'time_5_min': l10nEntry(english: '5 min', arabic: '5 د'),
    'improve_iqama_title': l10nEntry(
      english: 'Set your Iqama expiry date',
      arabic: 'حدّد تاريخ انتهاء الإقامة',
    ),
    'improve_iqama_desc': l10nEntry(
      english: 'Get reminders before your Iqama expires',
      arabic: 'احصل على تذكيرات قبل انتهاء الإقامة',
    ),
    'improve_join_group_title': l10nEntry(
      english: 'Join {groupName} group',
      arabic: 'انضم إلى مجموعة {groupName}',
    ),
    'improve_join_group_desc': l10nEntry(
      english: 'Connect with expats who share your background',
      arabic: 'تواصل مع مغتربين يشاركونك خلفيتك',
    ),
    'improve_skills_title': l10nEntry(
      english: 'Complete your skills profile',
      arabic: 'أكمل ملف مهاراتك',
    ),
    'improve_skills_desc': l10nEntry(
      english: 'Add HSE, safety or other skills to improve job matches',
      arabic: 'أضف HSE أو السلامة أو مهارات أخرى لتحسين تطابق الوظائف',
    ),
    'improve_profession_title': l10nEntry(
      english: 'Add your profession',
      arabic: 'أضف مهنتك',
    ),
    'improve_profession_desc': l10nEntry(
      english: 'Help Raabta AI personalize jobs and services for you',
      arabic: 'ساعد Raabta AI على تخصيص الوظائف والخدمات لك',
    ),
    'improve_certs_title': l10nEntry(
      english: 'Add certifications',
      arabic: 'أضف الشهادات',
    ),
    'improve_certs_desc': l10nEntry(
      english: 'NEBOSH, IOSH and other certs boost career score',
      arabic: 'شهادات NEBOSH و IOSH وغيرها تعزز نقاط المسار المهني',
    ),
    'improve_explore_jobs_title': l10nEntry(
      english: 'Explore job listings',
      arabic: 'استكشف قوائم الوظائف',
    ),
    'improve_explore_jobs_desc': l10nEntry(
      english: 'View 5+ jobs to activate your job search score',
      arabic: 'اعرض 5+ وظائف لتفعيل نقاط البحث عن عمل',
    ),
    'improve_save_job_title': l10nEntry(
      english: 'Save a job you like',
      arabic: 'احفظ وظيفة تعجبك',
    ),
    'improve_save_job_desc': l10nEntry(
      english: 'Saved jobs count toward your career engagement score',
      arabic: 'الوظائف المحفوظة تُحسب في نقاط تفاعلك المهني',
    ),
    'improve_housing_title': l10nEntry(
      english: 'Confirm your current housing',
      arabic: 'أكد سكنك الحالي',
    ),
    'improve_housing_desc': l10nEntry(
      english: 'Unlock housing insights tailored to your area',
      arabic: 'افتح رؤى سكنية مخصصة لمنطقتك',
    ),
    'improve_browse_housing_title': l10nEntry(
      english: 'Browse housing listings',
      arabic: 'تصفح قوائم السكن',
    ),
    'improve_browse_housing_desc': l10nEntry(
      english: 'Search and save listings to improve housing score',
      arabic: 'ابحث واحفظ القوائم لتحسين نقاط السكن',
    ),
    'improve_budget_title': l10nEntry(
      english: 'Set your monthly budget',
      arabic: 'حدّد ميزانيتك الشهرية',
    ),
    'improve_budget_desc': l10nEntry(
      english: 'Get better housing and salary recommendations',
      arabic: 'احصل على توصيات أفضل للسكن والراتب',
    ),
    'improve_transfer_title': l10nEntry(
      english: 'Set money transfer preference',
      arabic: 'حدّد تفضيل تحويل الأموال',
    ),
    'improve_transfer_desc': l10nEntry(
      english: 'Track remittance options on the Money screen',
      arabic: 'تتبع خيارات التحويل في شاشة Money',
    ),
    'improve_exchange_title': l10nEntry(
      english: 'Enable exchange rate alerts',
      arabic: 'فعّل تنبيهات أسعار الصرف',
    ),
    'improve_exchange_desc': l10nEntry(
      english: 'Stay updated on QAR exchange rates',
      arabic: 'ابقَ على اطلاع بأسعار صرف QAR',
    ),
    'improve_ask_qatar_title': l10nEntry(
      english: 'Answer a question on Ask Qatar',
      arabic: 'أجب على سؤال في Ask Qatar',
    ),
    'improve_ask_qatar_desc': l10nEntry(
      english: 'Help fellow expats and boost community score',
      arabic: 'ساعد المغتربين وعزّز نقاط المجتمع',
    ),
    'improve_doctor_title': l10nEntry(
      english: 'Set doctor language preference',
      arabic: 'حدّد تفضيل لغة الطبيب',
    ),
    'improve_doctor_desc': l10nEntry(
      english: 'Find doctors who speak your language',
      arabic: 'اعثر على أطباء يتحدثون لغتك',
    ),
    'improve_passport_title': l10nEntry(
      english: 'Add passport expiry date',
      arabic: 'أضف تاريخ انتهاء جواز السفر',
    ),
    'improve_passport_desc': l10nEntry(
      english: 'Never miss a renewal deadline',
      arabic: 'لا تفوت موعد التجديد',
    ),
    'improve_refer_title': l10nEntry(
      english: 'Refer a friend to Raabta',
      arabic: 'أحِل صديقاً إلى Raabta',
    ),
    'improve_refer_desc': l10nEntry(
      english:
          'Earn points — {remaining} more referrals to unlock Ambassador',
      arabic: 'اكسب نقاط — {remaining} إحالات إضافية لفتح Ambassador',
    ),
    'advice_unlock_profile': l10nEntry(
      english:
          'Complete your profile and Raabta tools to unlock a personalized score.',
      arabic: 'أكمل ملفك وأدوات Raabta لفتح درجة مخصصة.',
    ),
    'advice_category_attention': l10nEntry(
      english: '{category} needs attention: {why}',
      arabic: '{category} يحتاج اهتماماً: {why}',
    ),
    'advice_low_confidence': l10nEntry(
      english:
          '{category} confidence is reduced until you resolve a data mismatch between Raabta tools.',
      arabic:
          'ثقة {category} منخفضة حتى تحل تناقض البيانات بين أدوات Raabta.',
    ),
    'advice_add_signals': l10nEntry(
      english:
          'Add {category} signals in Raabta — we need more data before scoring this category.',
      arabic:
          'أضف إشارات {category} في Raabta — نحتاج المزيد من البيانات قبل تقييم هذه الفئة.',
    ),
    'advice_category_low': l10nEntry(
      english: 'Your {category} score is {pct}%. {action} could help fastest.',
      arabic: 'درجة {category} هي {pct}%. {action} قد يساعدك أسرع.',
    ),
    'advice_category_grow': l10nEntry(
      english:
          'Your {category} category has the most room to grow — start with {action}.',
      arabic: 'فئة {category} لديها أكبر مجال للنمو — ابدأ بـ {action}.',
    ),
    'advice_weekly_up': l10nEntry(
      english:
          'Your score rose {delta} points this week — keep the momentum going.',
      arabic: 'ارتفعت درجتك {delta} نقطة هذا الأسبوع — حافظ على الزخم.',
    ),
    'advice_on_track': l10nEntry(
      english:
          'You are on track. Small profile and tool updates still add points over time.',
      arabic:
          'أنت على المسار الصحيح. التحديثات الصغيرة للملف والأدوات تضيف نقاطاً مع الوقت.',
    ),
    'advice_default_empty': l10nEntry(
      english: 'Complete your profile to unlock personalized score advice.',
      arabic: 'أكمل ملفك لفتح نصائح درجة مخصصة.',
    ),
    'gap_housing_action': l10nEntry(
      english: 'Browse housing listings or set your preferred area',
      arabic: 'تصفح قوائم السكن أو حدّد منطقتك المفضلة',
    ),
    'gap_community_action': l10nEntry(
      english: 'Join a community group or post in Community',
      arabic: 'انضم إلى مجموعة أو انشر في Community',
    ),
    'gap_category_action': l10nEntry(
      english: 'Add more {category} data in Raabta',
      arabic: 'أضف المزيد من بيانات {category} في Raabta',
    ),
    'community_group_fallback': l10nEntry(
      english: 'your community',
      arabic: 'مجتمعك',
    ),
  };
}
