import 'package:raabta/features/know_qatar/data/know_qatar_catalog.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';

/// Pure client-side section ordering — no AI, no new Firestore fields.
abstract final class KnowQatarOrderService {
  /// Priority sections for users flagged as new arrivals in [ExpatLifeScore.level].
  static const _newArrivalPriority = [
    'work_in_qatar',
    'living_in_qatar',
    'residency_documents',
    'money_cost_of_living',
  ];

  /// Established residents see practical living sections slightly earlier.
  static const _establishedPriority = [
    'living_in_qatar',
    'money_cost_of_living',
    'work_in_qatar',
  ];

  static const _visitorIntroThenAlerts = [
    'qatar_at_glance',
    'alerts_safety',
  ];

  static List<String> resolveOrder({
    String? expatLifeLevel,
    KnowQatarPersona? persona,
  }) {
    final base = _resolveExpatOrder(expatLifeLevel);
    if (persona != KnowQatarPersona.visitor) return base;
    return _visitorOrder(base);
  }

  static List<String> _resolveExpatOrder(String? expatLifeLevel) {
    final level = expatLifeLevel?.trim().toLowerCase() ?? '';
    if (level.isEmpty) return List<String>.from(KnowQatarCatalog.defaultSectionOrder);

    final isNewArrival = level.contains('new') || level.contains('arrival');
    final priority = isNewArrival ? _newArrivalPriority : _establishedPriority;

    final ordered = <String>[];
    for (final key in priority) {
      if (KnowQatarCatalog.defaultSectionOrder.contains(key)) {
        ordered.add(key);
      }
    }
    for (final key in KnowQatarCatalog.defaultSectionOrder) {
      if (!ordered.contains(key)) ordered.add(key);
    }
    return ordered;
  }

  static List<String> _visitorOrder(List<String> base) {
    final ordered = <String>[];
    for (final key in _visitorIntroThenAlerts) {
      if (base.contains(key)) ordered.add(key);
    }
    for (final key in base) {
      if (!ordered.contains(key)) ordered.add(key);
    }
    return ordered;
  }
}
