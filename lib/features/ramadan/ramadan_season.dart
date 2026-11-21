import 'package:raabta/features/ramadan/hijri_calendar.dart';

/// Seasonal visibility for Ramadan features (~4 weeks before through end of Ramadan).
class RamadanSeason {
  RamadanSeason._();

  static const weeksBefore = 4;
  static const daysBefore = weeksBefore * 7;

  static bool isSeasonalPeriod([DateTime? reference]) {
    final now = dateOnly(reference ?? DateTime.now());
    if (isDuringRamadan(now)) return true;

    final nextStart = nextRamadanStartGregorian(now);
    final daysUntil = nextStart.difference(now).inDays;
    return daysUntil >= 0 && daysUntil <= daysBefore;
  }

  static int daysUntilRamadan([DateTime? reference]) {
    final now = dateOnly(reference ?? DateTime.now());
    if (isDuringRamadan(now)) return 0;
    return nextRamadanStartGregorian(now).difference(now).inDays;
  }

  static String seasonalLabel([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    if (isDuringRamadan(now)) {
      final hijri = gregorianToHijri(now);
      return 'Ramadan ${hijri.year} AH';
    }
    final days = daysUntilRamadan(now);
    if (days == 1) return 'Ramadan starts tomorrow';
    return 'Ramadan in $days days';
  }
}
