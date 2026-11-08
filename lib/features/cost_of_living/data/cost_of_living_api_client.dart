import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';

/// Fetches official NPC CPI / QoL data when the Raabta backend is unavailable
/// (e.g. route not deployed yet). Public open data — no API key.
abstract final class CostOfLivingApiClient {
  static const _apiBase =
      'https://www.data.gov.qa/api/explore/v2.1/catalog/datasets';
  static const _cpiDataset =
      'consumer-price-index-cpi-by-expenditure-group-monthly';
  static const _qolDataset = 'quality-of-life-index';

  static const _featuredCodes = {'0', '001', '004', '007', '008'};

  static const _monthOrder = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  static Future<CostOfLivingSnapshot?> fetchSnapshot() async {
    try {
      final cpiRecords = await _fetchAllCpiRecords();
      final qolRecords = await _fetchQualityOfLifeRecords();
      if (cpiRecords.isEmpty) return null;

      final cpi = _parseCpiRecords(cpiRecords);
      final qol = _parseQualityOfLifeRecords(qolRecords);
      if (cpi.sourceDateLabel == null) return null;

      CostOfLivingCategory? general;
      for (final c in cpi.categories) {
        if (c.code == '0') {
          general = c;
          break;
        }
      }

      return CostOfLivingSnapshot(
        id: 'direct_api',
        cpiSourceDateLabel: cpi.sourceDateLabel!,
        qolSourceDateLabel: qol?.sourceLabel,
        qualityOfLife: qol,
        categories: cpi.categories,
        generalCpi: general?.cpiIndex,
        fetchedAt: DateTime.now(),
        isDirectApi: true,
        disclaimer: CostOfLivingConstants.disclaimer,
      );
    } catch (e, st) {
      debugPrint('CostOfLivingApiClient: $e\n$st');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchAllCpiRecords() async {
    final records = <Map<String, dynamic>>[];
    var offset = 0;
    const limit = 100;

    while (true) {
      final uri = Uri.parse('$_apiBase/$_cpiDataset/records').replace(
        queryParameters: {'limit': '$limit', 'offset': '$offset'},
      );
      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        throw Exception('CPI HTTP ${res.statusCode}');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final batch = (body['results'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      records.addAll(batch);
      if (batch.length < limit) break;
      offset += limit;
      if (offset > 2000) break;
    }

    return records;
  }

  static Future<List<Map<String, dynamic>>> _fetchQualityOfLifeRecords() async {
    final uri = Uri.parse('$_apiBase/$_qolDataset/records').replace(
      queryParameters: {'limit': '20', 'order_by': 'year desc,time_period desc'},
    );
    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['results'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static int _periodSortKey(dynamic year, String? month) {
    final y = int.tryParse(year?.toString() ?? '') ?? 0;
    final m = _monthOrder[month] ?? 0;
    return y * 100 + m;
  }

  static String? _priorMonth(String month) {
    final current = _monthOrder[month];
    if (current == null) return null;
    if (current == 1) return 'Dec';
    return _monthOrder.entries
        .firstWhere((e) => e.value == current - 1)
        .key;
  }

  static ({List<CostOfLivingCategory> categories, String? sourceDateLabel})
      _parseCpiRecords(List<Map<String, dynamic>> records) {
    final byGroup = <String, ({int sortKey, Map<String, dynamic> row})>{};

    for (final row in records) {
      final code = row['group_code']?.toString().trim() ?? '';
      if (code.isEmpty) continue;
      final key = _periodSortKey(row['year'], row['month']?.toString());
      final existing = byGroup[code];
      if (existing == null || key > existing.sortKey) {
        byGroup[code] = (sortKey: key, row: row);
      }
    }

    final categories = <CostOfLivingCategory>[];
    String? sourceDateLabel;
    var maxSort = 0;

    for (final entry in byGroup.entries) {
      final code = entry.key;
      final latest = entry.value.row;
      final sortKey = entry.value.sortKey;

      if (sortKey > maxSort) {
        maxSort = sortKey;
        sourceDateLabel =
            '${latest['month']} ${latest['year']?.toString().trim()}';
      }

      final month = latest['month']?.toString() ?? '';
      final year = latest['year']?.toString() ?? '';
      final priorMonth = _priorMonth(month);
      final priorYear = _monthOrder[month] == 1
          ? (int.tryParse(year) ?? 0) - 1
          : int.tryParse(year) ?? 0;

      Map<String, dynamic>? priorRow;
      for (final r in records) {
        if (r['group_code']?.toString().trim() != code) continue;
        if (_periodSortKey(r['year'], r['month']?.toString()) ==
            _periodSortKey(
              priorMonth == 'Dec' ? priorYear : year,
              priorMonth,
            )) {
          priorRow = r;
          break;
        }
      }

      final currentIndex = (latest['cpi_index'] as num?)?.toDouble() ?? 0;
      final priorIndex = (priorRow?['cpi_index'] as num?)?.toDouble();

      categories.add(
        CostOfLivingCategory(
          code: code,
          name: latest['group']?.toString() ?? code,
          cpiIndex: currentIndex,
          priorIndex: priorIndex,
          trend: _trend(currentIndex, priorIndex),
          changePctMom: _changePct(currentIndex, priorIndex),
          featured: _featuredCodes.contains(code),
        ),
      );
    }

    categories.sort((a, b) {
      if (a.featured != b.featured) return a.featured ? -1 : 1;
      return a.code.compareTo(b.code);
    });

    return (categories: categories, sourceDateLabel: sourceDateLabel);
  }

  static QualityOfLifeSnapshot? _parseQualityOfLifeRecords(
    List<Map<String, dynamic>> records,
  ) {
    if (records.isEmpty) return null;

    const periodRank = {'Early': 1, 'Mid': 2};
    Map<String, dynamic>? best;
    var bestKey = -1;

    for (final row in records) {
      final year = int.tryParse(row['year']?.toString() ?? '') ?? 0;
      final pr = periodRank[row['time_period']?.toString()] ?? 0;
      final key = year * 10 + pr;
      if (key > bestKey) {
        bestKey = key;
        best = row;
      }
    }

    if (best == null) return null;

    return QualityOfLifeSnapshot(
      score: (best['score'] as num?)?.toDouble() ?? 0,
      rank: (best['rank'] as num?)?.toInt() ?? 0,
      year: best['year']?.toString() ?? '',
      timePeriod: best['time_period']?.toString() ?? '',
      sourceLabel: '${best['year']} ${best['time_period']}',
    );
  }

  static CostOfLivingTrend _trend(double current, double? prior) {
    if (prior == null || prior == 0) return CostOfLivingTrend.flat;
    final delta = current - prior;
    if (delta.abs() < 0.01) return CostOfLivingTrend.flat;
    return delta > 0 ? CostOfLivingTrend.up : CostOfLivingTrend.down;
  }

  static double? _changePct(double current, double? prior) {
    if (prior == null || prior == 0) return null;
    return double.parse(
      (((current - prior) / prior) * 100).toStringAsFixed(2),
    );
  }
}
