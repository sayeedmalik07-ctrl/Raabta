import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/money_comparator/data/models/corridor_aggregate_model.dart';
import 'package:raabta/features/money_comparator/data/repository/corridor_comparator_repository.dart';
import 'package:raabta/features/money_comparator/domain/corridor_aggregate_logic.dart';
import 'package:raabta/services/exchange_rate_service.dart';

final corridorComparatorRepositoryProvider =
    Provider<CorridorComparatorRepository>(
  (ref) => CorridorComparatorRepository(),
);

final corridorSelectedCountryProvider = StateProvider<String>((ref) => 'INR');

final corridorSendAmountProvider = StateProvider<double>((ref) => 1000);

enum CorridorSortMode { bestValue, fastest }

final corridorSortModeProvider =
    StateProvider<CorridorSortMode>((ref) => CorridorSortMode.bestValue);

final corridorAggregatesProvider = FutureProvider.autoDispose
    .family<CorridorAggregatesResult, String>((ref, countryCode) async {
  final repo = ref.watch(corridorComparatorRepositoryProvider);
  return repo.fetchAggregatesForCountry(countryCode: countryCode);
});

final corridorKnownProvidersProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.watch(corridorComparatorRepositoryProvider);
  return repo.knownProviderNames();
});

/// Ranked rows for the comparator — deterministic Dart only.
class CorridorComparisonRow {
  const CorridorComparisonRow({
    required this.aggregate,
    required this.estimatedRecipientGets,
    required this.recipientGetsPer100Qar,
  });

  final CorridorAggregate aggregate;
  final double estimatedRecipientGets;
  final double recipientGetsPer100Qar;
}

List<CorridorComparisonRow> buildComparisonRows({
  required List<CorridorAggregate> aggregates,
  required double amountSentQar,
  required CorridorSortMode sortMode,
}) {
  final rows = <CorridorComparisonRow>[];
  for (final agg in aggregates) {
    if (!CorridorAggregateLogic.hasEnoughData(agg.reportCount)) continue;
    final estimated = CorridorAggregateLogic.estimateRecipientGets(
      amountSentQar: amountSentQar,
      avgFeePaidQar: agg.avgFeePaidQar,
      avgEffectiveRate: agg.avgEffectiveRate,
    );
    final per100 = CorridorAggregateLogic.recipientGetsPer100Qar(
      avgEffectiveRate: agg.avgEffectiveRate,
      avgFeePaidQar: agg.avgFeePaidQar,
    );
    rows.add(
      CorridorComparisonRow(
        aggregate: agg,
        estimatedRecipientGets: estimated,
        recipientGetsPer100Qar: per100,
      ),
    );
  }

  if (sortMode == CorridorSortMode.fastest) {
    rows.sort(
      (a, b) => a.aggregate.avgDeliveryHours
          .compareTo(b.aggregate.avgDeliveryHours),
    );
  } else {
    rows.sort(
      (a, b) =>
          b.estimatedRecipientGets.compareTo(a.estimatedRecipientGets),
    );
  }
  return rows;
}

CurrencyInfo? currencyInfoForCode(String code) {
  for (final c in raabtaCurrencies) {
    if (c.code == code) return c;
  }
  return null;
}
