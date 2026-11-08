/// Canonical decimal formatting for certificate fingerprint payloads.
abstract final class EosbCertificateDecimalFormat {
  static String money(double value) => fixed(value, 2);

  static String serviceYears(double value) => fixed(value, 4);

  static String score(double value) => fixed(value, 4);

  static String fixed(double value, int places) {
    assert(places >= 0);
    final factor = _pow10(places);
    final scaled = (value * factor).round();
    final negative = scaled < 0;
    final abs = scaled.abs();
    final whole = abs ~/ factor;
    final frac = abs % factor;
    final fracStr = frac.toString().padLeft(places, '0');
    return negative ? '-$whole.$fracStr' : '$whole.$fracStr';
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  static String isoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String isoDateTimeUtc(DateTime dateTime) {
    final u = dateTime.toUtc();
    final y = u.year.toString().padLeft(4, '0');
    final m = u.month.toString().padLeft(2, '0');
    final d = u.day.toString().padLeft(2, '0');
    final h = u.hour.toString().padLeft(2, '0');
    final min = u.minute.toString().padLeft(2, '0');
    final s = u.second.toString().padLeft(2, '0');
    final ms = u.millisecond.toString().padLeft(3, '0');
    return '$y-$m-${d}T$h:$min:$s.${ms}Z';
  }
}
