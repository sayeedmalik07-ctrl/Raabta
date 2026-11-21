import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_provider_rate_model.dart';
import 'package:raabta/features/money_comparator/data/repository/remittance_truth_repository.dart';
import 'package:raabta/features/money_comparator/domain/remittance_truth_calculator.dart';

final remittanceTruthRepositoryProvider = Provider<RemittanceTruthRepository>(
  (ref) => RemittanceTruthRepository(),
);

final remittanceMidMarketProvider =
    FutureProvider.autoDispose<RemittanceMidMarketResult>((ref) async {
  final repo = ref.watch(remittanceTruthRepositoryProvider);
  return repo.fetchMidMarketWithCache();
});

final remittanceProviderRatesProvider = FutureProvider.autoDispose
    .family<RemittanceProviderRatesResult, String>((ref, countryCode) async {
  final repo = ref.watch(remittanceTruthRepositoryProvider);
  return repo.fetchProviderRatesWithCache(countryCode);
});

/// Reactive comparison rows — recalculates when amount or corridor changes.
final remittanceComparisonRowsProvider = Provider.autoDispose
    .family<List<RemittanceProviderComparisonRow>, RemittanceComparisonInput>(
  (ref, input) {
    final mid = input.midMarketRate;
    if (mid == null || mid <= 0) return const [];

    final rows = <RemittanceProviderComparisonRow>[];
    for (final provider in input.providers) {
      final effective = RemittanceTruthCalculator.providerEffectiveRate(
        midMarketRate: mid,
        fxMarginPercent: provider.fxMarginPercent,
      );
      final recipientGets = RemittanceTruthCalculator.recipientGetsForeign(
        amountSentQar: input.amountSentQar,
        midMarketRate: mid,
        fxMarginPercent: provider.fxMarginPercent,
        flatFeeQar: provider.flatFeeQar,
      );
      final hidden = RemittanceTruthCalculator.hiddenMarkupQar(
        amountSentQar: input.amountSentQar,
        midMarketRate: mid,
        fxMarginPercent: provider.fxMarginPercent,
      );
      final totalCost = RemittanceTruthCalculator.totalCostQar(
        amountSentQar: input.amountSentQar,
        midMarketRate: mid,
        fxMarginPercent: provider.fxMarginPercent,
        flatFeeQar: provider.flatFeeQar,
      );
      rows.add(
        RemittanceProviderComparisonRow(
          provider: provider,
          midMarketRate: mid,
          providerEffectiveRate: effective,
          recipientGetsForeign: recipientGets,
          hiddenMarkupQar: hidden,
          totalCostQar: totalCost,
          totalCostPercent: RemittanceTruthCalculator.totalCostPercent(
            amountSentQar: input.amountSentQar,
            totalCostQar: totalCost,
          ),
        ),
      );
    }

    rows.sort((a, b) => b.recipientGetsForeign.compareTo(a.recipientGetsForeign));
    return rows;
  },
);

class RemittanceComparisonInput {
  const RemittanceComparisonInput({
    required this.amountSentQar,
    required this.providers,
    required this.midMarketRate,
  });

  final double amountSentQar;
  final List<RemittanceProviderRate> providers;
  final double? midMarketRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemittanceComparisonInput &&
          amountSentQar == other.amountSentQar &&
          midMarketRate == other.midMarketRate &&
          _listEquals(providers, other.providers);

  @override
  int get hashCode =>
      Object.hash(amountSentQar, midMarketRate, Object.hashAll(providers));

  static bool _listEquals(
    List<RemittanceProviderRate> a,
    List<RemittanceProviderRate> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
