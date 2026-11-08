import 'dart:convert';

import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists day stats + chart points on-device when backend/Firestore are unavailable.
class GoldLocalStore {
  static const _dayKey = 'gold_qatar_day_key';
  static const _yesterdayClose = 'gold_qatar_yesterday_close';
  static const _dayHigh = 'gold_qatar_day_high';
  static const _dayLow = 'gold_qatar_day_low';
  static const _dayOpen = 'gold_qatar_day_open';
  static const _intraday = 'gold_qatar_intraday_json';
  static const _dailyCloses = 'gold_qatar_daily_closes_json';

  Future<({
    double? yesterdayClose,
    double dayHigh,
    double dayLow,
    double dayOpen,
    double? pctVsYesterday,
    double? qarDeltaVsYesterday,
  })> recordLivePrice(double price24k) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dohaDayKey(DateTime.now());
    final storedDay = prefs.getString(_dayKey);

    double? yesterdayClose = prefs.getDouble(_yesterdayClose);
    double dayHigh;
    double dayLow;
    double dayOpen;

    if (storedDay != today) {
      final lastPrice = prefs.getDouble('gold_qatar_last_price');
      if (lastPrice != null && storedDay != null) {
        yesterdayClose = lastPrice;
        await prefs.setDouble(_yesterdayClose, lastPrice);
        await _appendDailyClose(prefs, storedDay, lastPrice);
      }
      await prefs.setString(_dayKey, today);
      dayOpen = price24k;
      dayHigh = price24k;
      dayLow = price24k;
      await prefs.setDouble(_dayOpen, dayOpen);
      await prefs.setDouble(_dayHigh, dayHigh);
      await prefs.setDouble(_dayLow, dayLow);
      await prefs.setString(_intraday, jsonEncode([]));
    } else {
      dayOpen = prefs.getDouble(_dayOpen) ?? price24k;
      dayHigh = prefs.getDouble(_dayHigh) ?? price24k;
      dayLow = prefs.getDouble(_dayLow) ?? price24k;
      dayHigh = dayHigh > price24k ? dayHigh : price24k;
      dayLow = dayLow < price24k ? dayLow : price24k;
      await prefs.setDouble(_dayHigh, dayHigh);
      await prefs.setDouble(_dayLow, dayLow);
    }

    await prefs.setDouble('gold_qatar_last_price', price24k);
    await _appendIntradayPoint(prefs, price24k);

    double? pctVsYesterday;
    double? qarDelta;
    if (yesterdayClose != null && yesterdayClose > 0) {
      qarDelta = double.parse((price24k - yesterdayClose).toStringAsFixed(2));
      pctVsYesterday = double.parse(
        (((price24k - yesterdayClose) / yesterdayClose) * 100).toStringAsFixed(2),
      );
    }

    return (
      yesterdayClose: yesterdayClose,
      dayHigh: dayHigh,
      dayLow: dayLow,
      dayOpen: dayOpen,
      pctVsYesterday: pctVsYesterday,
      qarDeltaVsYesterday: qarDelta,
    );
  }

  Future<List<GoldHistoryPoint>> intradayPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodePoints(prefs.getString(_intraday));
  }

  Future<List<GoldHistoryPoint>> rangePoints(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final daily = _decodeDailyCloses(prefs.getString(_dailyCloses));
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return daily
        .where((p) {
          final d = DateTime.tryParse(p.date);
          return d != null && d.isAfter(cutoff);
        })
        .toList();
  }

  Future<List<GoldHistoryPoint>> todayPoints() => intradayPoints();

  Future<void> _appendIntradayPoint(SharedPreferences prefs, double price) async {
    final points = _decodePoints(prefs.getString(_intraday));
    points.add(
      GoldHistoryPoint(
        date: DateTime.now().toUtc().toIso8601String(),
        price: price,
      ),
    );
    // Keep last 48 intraday ticks (~24h at 30 min).
    final trimmed = points.length > 48 ? points.sublist(points.length - 48) : points;
    await prefs.setString(_intraday, jsonEncode(trimmed.map(_pointToJson).toList()));
  }

  Future<void> _appendDailyClose(
    SharedPreferences prefs,
    String dayKey,
    double price,
  ) async {
    final daily = _decodeDailyCloses(prefs.getString(_dailyCloses));
    daily.removeWhere((p) => p.date.startsWith(dayKey));
    daily.add(GoldHistoryPoint(date: dayKey, price: price));
    daily.sort((a, b) => a.date.compareTo(b.date));
    final trimmed = daily.length > 400 ? daily.sublist(daily.length - 400) : daily;
    await prefs.setString(
      _dailyCloses,
      jsonEncode(trimmed.map(_pointToJson).toList()),
    );
  }

  List<GoldHistoryPoint> _decodePoints(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => GoldHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<GoldHistoryPoint> _decodeDailyCloses(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => GoldHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _pointToJson(GoldHistoryPoint p) => {
        'date': p.date,
        'gold_24k_qar_per_gram': p.price,
      };

  String _dohaDayKey(DateTime dt) {
    final utc = dt.toUtc().add(const Duration(hours: 3));
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
  }
}
