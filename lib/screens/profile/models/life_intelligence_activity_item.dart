import 'package:raabta/services/life_intelligence_signals_service.dart';

/// Advisory Life Intelligence row for Profile → My Activity (V2).
class LifeIntelligenceActivityItem {
  const LifeIntelligenceActivityItem({
    required this.sourceId,
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.route,
    required this.sortTime,
    required this.ackToken,
  });

  final String sourceId;
  final LifeIntelligenceSignalType type;
  final String titleKey;
  final String bodyKey;
  final String route;
  final DateTime sortTime;
  final String ackToken;
}
