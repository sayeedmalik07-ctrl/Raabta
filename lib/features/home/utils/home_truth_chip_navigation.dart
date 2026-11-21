import 'package:raabta/features/home/domain/truth_chip_status.dart';

/// Chip tap route — deep links for attention/urgent; engine home otherwise.
String resolveTruthChipTapRoute(TruthChipStatus status) {
  if (status.state == TruthChipState.attention ||
      status.state == TruthChipState.urgent) {
    return status.deepLink;
  }
  return status.engine.homeRoute;
}
