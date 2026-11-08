import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/money_comparator/data/corridor_comparator_local_cache.dart';
import 'package:raabta/features/money_comparator/data/models/corridor_aggregate_model.dart';
import 'package:raabta/features/money_comparator/data/models/corridor_report_model.dart';
import 'package:raabta/features/money_comparator/domain/corridor_aggregate_logic.dart';

/// Pull-based Firestore access — comparator reads **aggregates only**, never raw reports.
class CorridorComparatorRepository {
  CorridorComparatorRepository({
    FirebaseFirestore? firestore,
    CorridorComparatorLocalCache? cache,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cache = cache ?? CorridorComparatorLocalCache.instance;

  final FirebaseFirestore _firestore;
  final CorridorComparatorLocalCache _cache;

  static const reportsCollection = 'corridor_reports';
  static const aggregatesCollection = 'corridor_aggregates';

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection(reportsCollection);

  CollectionReference<Map<String, dynamic>> get _aggregatesRef =>
      _firestore.collection(aggregatesCollection);

  /// Reads only `corridor_aggregates` for display — cached 20 min.
  Future<CorridorAggregatesResult> fetchAggregatesForCountry({
    required String countryCode,
    bool forceRefresh = false,
  }) async {
    final code = countryCode.toUpperCase();
    await _cache.init();
    if (!forceRefresh && await _cache.isFresh(code)) {
      final cached = await _cache.loadAggregates(code);
      if (cached != null) {
        return CorridorAggregatesResult(
          aggregates: cached,
          fromCache: true,
          cachedAt: await _cache.cachedAt(code),
        );
      }
    }

    try {
      final snap = await _aggregatesRef
          .where('destinationCountryCode', isEqualTo: code)
          .get();
      final aggregates = snap.docs.map(CorridorAggregate.fromFirestore).toList();
      await _cache.cacheAggregates(code, aggregates);
      return CorridorAggregatesResult(
        aggregates: aggregates,
        fromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('CorridorComparatorRepository fetch failed: $e');
      final stale = await _cache.loadAggregates(code);
      if (stale != null) {
        return CorridorAggregatesResult(
          aggregates: stale,
          fromCache: true,
          cachedAt: await _cache.cachedAt(code),
          isStale: true,
        );
      }
      rethrow;
    }
  }

  /// Submit report + transactional aggregate update (rolling averages).
  Future<void> submitReport({
    required CorridorReport report,
    required String userId,
  }) async {
    final payload = report.toFirestore()..['userId'] = userId;
    final docRef = await _reportsRef.add(payload);

    final aggregateId = CorridorReport.aggregateDocId(
      countryCode: report.destinationCountryCode,
      method: report.method,
      providerName: report.providerName,
    );

    final effectiveRate = CorridorAggregateLogic.effectiveRateFromReport(report);

    await _firestore.runTransaction((tx) async {
      final aggRef = _aggregatesRef.doc(aggregateId);
      final snap = await tx.get(aggRef);
      final data = snap.data();

      final prevCount = (data?['reportCount'] as num?)?.toInt() ?? 0;
      final rateUpdate = CorridorAggregateLogic.updateRollingAverage(
        currentCount: prevCount,
        currentAverage: (data?['avgEffectiveRate'] as num?)?.toDouble() ?? 0,
        newValue: effectiveRate,
      );
      final feeUpdate = CorridorAggregateLogic.updateRollingAverage(
        currentCount: prevCount,
        currentAverage: (data?['avgFeePaidQar'] as num?)?.toDouble() ?? 0,
        newValue: report.feePaidQar,
      );
      final hoursUpdate = CorridorAggregateLogic.updateRollingAverage(
        currentCount: prevCount,
        currentAverage: (data?['avgDeliveryHours'] as num?)?.toDouble() ?? 0,
        newValue: report.deliveryHours,
      );

      tx.set(
        aggRef,
        {
          'destinationCountryCode': report.destinationCountryCode,
          'destinationCurrencyCode': report.destinationCurrencyCode,
          'destinationCountryName': report.destinationCountryName,
          'method': report.method.value,
          'providerName': report.providerName.trim(),
          'reportCount': rateUpdate.count,
          'avgEffectiveRate': rateUpdate.average,
          'avgFeePaidQar': feeUpdate.average,
          'avgDeliveryHours': hoursUpdate.average,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastReportId': docRef.id,
        },
        SetOptions(merge: true),
      );
    });

    await _cache.appendProviderName(report.providerName);
    await _cache.invalidateCountry(report.destinationCountryCode);
  }

  Future<List<String>> knownProviderNames() => _cache.loadProviderNames();
}

class CorridorAggregatesResult {
  const CorridorAggregatesResult({
    required this.aggregates,
    required this.fromCache,
    this.cachedAt,
    this.isStale = false,
  });

  final List<CorridorAggregate> aggregates;
  final bool fromCache;
  final DateTime? cachedAt;
  final bool isStale;
}
