import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';

/// B0/B2 gate — reporting stays hidden until verified. B1 uses [showStaticWorkerRightsCard].
abstract final class HeatViolationReportConfig {
  /// Flip to true only after Ministry of Labour hotline/email are confirmed in-product.
  static const bool verified = false;

  /// B1 static educational rights card (independent of [verified]).
  static const bool showStaticWorkerRightsCard = true;

  /// @deprecated Use [showStaticWorkerRightsCard] for B1 and [showReportActions] for B2.
  static bool get showRightsCard => showStaticWorkerRightsCard;

  static bool get showReportActions => verified;

  /// Report CTA (Part B2) — season + verification; always false while [verified] is false.
  static bool isReportVisible({required DateTime evaluatedAtQatarLocal}) {
    if (!verified) return false;
    return _isWithinReportSeason(evaluatedAtQatarLocal);
  }

  static bool _isWithinReportSeason(DateTime local) {
    final m = local.month;
    final d = local.day;
    if (m < QatarOutdoorWorkRules.seasonStartMonth) return false;
    if (m > QatarOutdoorWorkRules.seasonEndMonth) return false;
    if (m == QatarOutdoorWorkRules.seasonStartMonth &&
        d < QatarOutdoorWorkRules.seasonStartDay) {
      return false;
    }
    if (m == QatarOutdoorWorkRules.seasonEndMonth &&
        d > QatarOutdoorWorkRules.seasonEndDay) {
      return false;
    }
    return true;
  }
}
