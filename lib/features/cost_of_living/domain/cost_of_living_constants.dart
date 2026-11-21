/// Qatar Cost of Living — constants and copy.
abstract final class CostOfLivingConstants {
  static const disclaimer =
      'Sourced from Qatar\'s official Open Data portal (data.gov.qa) and '
      'National Planning Council. Data updates monthly (CPI) and twice yearly '
      '(Quality of Life Index) — not real-time. For informational context, '
      'not a substitute for your own budgeting.';

  static const personalComparisonDisclaimer =
      'Directional context only. CPI tracks national price levels for a '
      'standard basket — not your individual bills. Your tracked amounts '
      'reflect what you entered in Bill Tracker, not an official cost estimate.';

  static const aiSummaryDisclaimer =
      'AI summary explains official figures only — not financial advice.';

  /// Bill Tracker category → CPI group code (data.gov.qa monthly dataset).
  static const billCategoryToCpiCode = <String, String>{
    'Electricity & Water': '004',
    'Telecom': '008',
    'District Cooling': '004',
    'Gas': '004',
    'Housing': '004',
    'Entertainment': '009',
  };

  static const featuredCategoryLabels = <String, String>{
    '0': 'General index',
    '001': 'Food & beverages',
    '004': 'Housing & utilities',
    '007': 'Transport',
    '008': 'Communication',
  };
}

enum CostOfLivingTrend { up, down, flat }

CostOfLivingTrend trendFromString(String? value) {
  return switch (value) {
    'up' => CostOfLivingTrend.up,
    'down' => CostOfLivingTrend.down,
    _ => CostOfLivingTrend.flat,
  };
}

String trendLabel(CostOfLivingTrend trend) {
  return switch (trend) {
    CostOfLivingTrend.up => 'Rising',
    CostOfLivingTrend.down => 'Falling',
    CostOfLivingTrend.flat => 'Stable',
  };
}
