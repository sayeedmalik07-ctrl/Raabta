/// Tabular Islamic (Hijri) calendar conversion — fully offline.
class HijriDate {
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  static const ramadanMonth = 9;
}

int _gregorianToJulianDay(int year, int month, int day) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = y ~/ 100;
  final b = 2 - a + (a ~/ 4);
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      b -
      1524;
}

HijriDate gregorianToHijri(DateTime date) {
  var jd = _gregorianToJulianDay(date.year, date.month, date.day);
  jd = jd - 1948440 + 10632;
  final n = ((jd - 1) / 10631).floor();
  jd = jd - 10631 * n + 354;
  final j = ((10985 - jd) / 5316).floor() * ((50 * jd) / 17719).floor() +
      (jd ~/ 5670) * ((43 * jd) / 15238).floor();
  final l = jd -
      ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
      (j ~/ 16) * ((15238 * j) / 43).floor() +
      29;
  final month = ((24 * l) / 709).floor();
  final day = l - ((709 * month) / 24).floor();
  final year = 30 * n + j - 30;
  return HijriDate(year: year, month: month, day: day);
}

DateTime hijriToGregorian(int year, int month, int day) {
  final jd = (day +
          (29.5 * (month - 1)).ceil() +
          (year - 1) * 354 +
          ((3 + 11 * year) / 30).floor() +
          1948440 -
          385);
  return _julianDayToGregorian(jd);
}

DateTime _julianDayToGregorian(int jd) {
  final l = jd + 68569;
  final n = (4 * l) ~/ 146097;
  final l2 = l - ((146097 * n + 3) ~/ 4);
  final i = (4000 * (l2 + 1)) ~/ 1461001;
  final l3 = l2 - ((1461 * i) ~/ 4) + 31;
  final j = (80 * l3) ~/ 2447;
  final day = l3 - ((2447 * j) ~/ 80);
  final l4 = j ~/ 11;
  final month = j + 2 - 12 * l4;
  final year = 100 * (n - 49) + i + l4;
  return DateTime(year, month, day);
}

DateTime dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Next Gregorian date when Hijri month 9 (Ramadan) begins.
DateTime nextRamadanStartGregorian([DateTime? from]) {
  final start = dateOnly(from ?? DateTime.now());
  for (var i = 0; i <= 400; i++) {
    final candidate = start.add(Duration(days: i));
    final hijri = gregorianToHijri(candidate);
    if (hijri.month == HijriDate.ramadanMonth && hijri.day == 1) {
      return candidate;
    }
  }
  return start.add(const Duration(days: 365));
}

bool isDuringRamadan([DateTime? reference]) {
  final hijri = gregorianToHijri(reference ?? DateTime.now());
  return hijri.month == HijriDate.ramadanMonth;
}
