import 'package:raabta/features/health_insurance/data/moph_insurer_lookup_catalog.dart';

/// Legacy helpers — prefer [InsurerLookupService] for TPA/plan resolution.
abstract final class MophRegisteredInsurers {
  static const firestoreDocId = MophInsurerLookupCatalog.firestoreDocId;

  static List<String> get defaultInsurers =>
      MophInsurerLookupCatalog.defaultInsurers;

  static DateTime get seedLastVerified =>
      MophInsurerLookupCatalog.seedLastVerified;

  static bool isRegistered(String name, {List<String>? overrideList}) {
    final normalized = _normalize(name);
    if (normalized.isEmpty) return false;
    final list = overrideList ?? defaultInsurers;
    return list.any((i) => _normalize(i) == normalized);
  }

  static String _normalize(String value) =>
      MophInsurerLookupCatalog.normalize(value);
}
