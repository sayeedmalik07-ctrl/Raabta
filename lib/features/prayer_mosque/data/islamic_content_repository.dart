import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';

/// Offline Islamic daily content and calendar events.
class IslamicContentRepository {
  static const _quotes = [
    'Verily, with hardship comes ease. — Quran 94:6',
    'The best among you are those who learn the Quran and teach it.',
    'Allah does not burden a soul beyond that it can bear. — Quran 2:286',
    'Speak good or remain silent. — Hadith',
    'The strong person is not the one who wrestles, but controls anger.',
  ];

  static const _hadiths = [
    'The first thing for which a person will be brought to account is prayer.',
    'Whoever builds a mosque for Allah, Allah will build for him a house in Paradise.',
    'The closest a servant is to his Lord is while prostrating.',
    'Make things easy and do not make them difficult.',
  ];

  static const _duas = [
    'Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah.',
    'Allahumma inni as\'aluka al-afwa wal-afiyah.',
    'SubhanAllah, Alhamdulillah, Allahu Akbar.',
    'Rabbishrahli sadri wa yassir li amri.',
  ];

  static const _verses = [
    'Indeed, prayer prohibits immorality and wrongdoing. — Quran 29:45',
    'And establish prayer and give zakah. — Quran 2:43',
    'So remember Me; I will remember you. — Quran 2:152',
  ];

  static const _morningAzkar = [
    'Astaghfirullah (3x), SubhanAllah (33x), Alhamdulillah (33x), Allahu Akbar (34x).',
    'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama.',
  ];

  static const _eveningAzkar = [
    'A\'udhu bikalimatillahit-tammati min sharri ma khalaq.',
    'Allahumma bika amsaina wa bika asbahna wa bika nahya wa bika namutu.',
  ];

  IslamicDailyContent forDay([DateTime? date]) {
    final d = date ?? DateTime.now();
    final index = d.day + d.month * 7;
    return IslamicDailyContent(
      quote: _quotes[index % _quotes.length],
      hadith: _hadiths[index % _hadiths.length],
      dua: _duas[index % _duas.length],
      verse: _verses[index % _verses.length],
      morningAzkar: _morningAzkar[index % _morningAzkar.length],
      eveningAzkar: _eveningAzkar[index % _eveningAzkar.length],
    );
  }

  List<IslamicCalendarEvent> upcomingEvents([DateTime? from]) {
    final start = from ?? DateTime.now();
    final events = <IslamicCalendarEvent>[];
    for (var i = 0; i <= 400; i++) {
      final day = start.add(Duration(days: i));
      final hijri = gregorianToHijri(day);
      final event = _eventForHijri(hijri.month, hijri.day, day);
      if (event != null) events.add(event);
    }
    return events.take(8).toList();
  }

  IslamicCalendarEvent? _eventForHijri(int month, int day, DateTime greg) {
    if (month == 1 && day == 1) {
      return IslamicCalendarEvent(
        titleKey: 'event_islamic_new_year',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🌙',
      );
    }
    if (month == 9 && day == 1) {
      return IslamicCalendarEvent(
        titleKey: 'event_ramadan',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🌙',
      );
    }
    if (month == 9 && day == 27) {
      return IslamicCalendarEvent(
        titleKey: 'event_laylatul_qadr',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '✨',
      );
    }
    if (month == 10 && day == 1) {
      return IslamicCalendarEvent(
        titleKey: 'event_eid_fitr',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🎉',
      );
    }
    if (month == 12 && day == 10) {
      return IslamicCalendarEvent(
        titleKey: 'event_eid_adha',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🕋',
      );
    }
    if (month == 1 && day == 10) {
      return IslamicCalendarEvent(
        titleKey: 'event_ashura',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🕌',
      );
    }
    if (month == 3 && day == 12) {
      return IslamicCalendarEvent(
        titleKey: 'event_mawlid',
        hijriMonth: month,
        hijriDay: day,
        gregorianDate: greg,
        emoji: '🌟',
      );
    }
    return null;
  }

  static const hijriMonthNames = {
    1: 'Muharram',
    2: 'Safar',
    3: 'Rabi al-Awwal',
    4: 'Rabi al-Thani',
    5: 'Jumada al-Awwal',
    6: 'Jumada al-Thani',
    7: 'Rajab',
    8: 'Sha\'ban',
    9: 'Ramadan',
    10: 'Shawwal',
    11: 'Dhu al-Qi\'dah',
    12: 'Dhu al-Hijjah',
  };
}
