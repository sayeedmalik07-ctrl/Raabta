import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker_screen.dart';

/// Builds honest directional comparisons between Bill Tracker and CPI trends.
class PersonalComparisonService {
  List<PersonalCostComparison> buildComparisons({
    required CostOfLivingSnapshot snapshot,
    required List<BillEntry> bills,
  }) {
    if (bills.isEmpty) return [];

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final comparisons = <PersonalCostComparison>[];

    for (final entry in CostOfLivingConstants.billCategoryToCpiCode.entries) {
      final billCategory = entry.key;
      final cpiCode = entry.value;
      final cpiCat = snapshot.categoryByCode(cpiCode);
      if (cpiCat == null) continue;

      final thisTotal = _sumForMonth(bills, billCategory, thisMonth);
      final lastTotal = _sumForMonth(bills, billCategory, lastMonth);
      if (thisTotal <= 0 && lastTotal <= 0) continue;

      final userTrend = _userTrend(thisTotal, lastTotal);
      final cpiTrend = trendLabel(cpiCat.trend);
      final aligned = _trendsAlign(userTrend, cpiCat.trend);

      comparisons.add(
        PersonalCostComparison(
          categoryLabel: cpiCat.displayName,
          userTrendLabel: userTrend,
          cpiTrendLabel: cpiTrend,
          cpiSourceDateLabel: snapshot.cpiSourceDateLabel,
          aligned: aligned,
          body: _body(
            billCategory: billCategory,
            userTrend: userTrend,
            cpiTrend: cpiTrend,
            cpiDate: snapshot.cpiSourceDateLabel,
            aligned: aligned,
          ),
        ),
      );
    }

    return comparisons;
  }

  double _sumForMonth(
    List<BillEntry> bills,
    String category,
    DateTime monthStart,
  ) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1);
    return bills
        .where((b) => b.category == category)
        .where((b) {
          final d = b.dueDate;
          return !d.isBefore(monthStart) && d.isBefore(monthEnd);
        })
        .fold<double>(0, (sum, b) => sum + b.amount);
  }

  String _userTrend(double current, double prior) {
    if (prior <= 0 && current > 0) return 'Higher than last month';
    if (current <= 0 && prior > 0) return 'Lower than last month';
    if ((current - prior).abs() < 1) return 'Similar to last month';
    return current > prior ? 'Trending up' : 'Trending down';
  }

  bool _trendsAlign(String userTrend, CostOfLivingTrend cpiTrend) {
    if (userTrend.contains('up') || userTrend.contains('Higher')) {
      return cpiTrend == CostOfLivingTrend.up;
    }
    if (userTrend.contains('down') || userTrend.contains('Lower')) {
      return cpiTrend == CostOfLivingTrend.down;
    }
    return cpiTrend == CostOfLivingTrend.flat;
  }

  String _body({
    required String billCategory,
    required String userTrend,
    required String cpiTrend,
    required String cpiDate,
    required bool aligned,
  }) {
    final alignPhrase = aligned
        ? 'roughly the same direction as'
        : 'a different direction from';
    return 'Your tracked $billCategory spending is $userTrend. '
        'Qatar\'s official ${CostOfLivingConstants.featuredCategoryLabels[CostOfLivingConstants.billCategoryToCpiCode[billCategory]] ?? billCategory} '
        'index was $cpiTrend in the latest release ($cpiDate) — $alignPhrase '
        'your own totals. This is directional context, not a precise personal '
        'cost calculation.';
  }
}
