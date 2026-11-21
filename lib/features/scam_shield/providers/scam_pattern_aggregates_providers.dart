import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/data/scam_pattern_report_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_pattern_aggregate_lookup.dart';
import 'package:raabta/features/scam_shield/services/scam_pattern_aggregates_service.dart';

final scamPatternReportRepositoryProvider =
    Provider<ScamPatternReportRepository>((ref) {
  return ScamPatternReportRepository();
});

final scamPatternAggregatesServiceProvider =
    Provider<ScamPatternAggregatesService>((ref) {
  return ScamPatternAggregatesService();
});

/// Read-only anonymized aggregates for a Qatar area (Part D — map overlay input).
final scamPatternAggregatesProvider =
    FutureProvider.family<ScamPatternAreaAggregates, String>((ref, area) async {
  final service = ref.watch(scamPatternAggregatesServiceProvider);
  return service.fetchByArea(area);
});
