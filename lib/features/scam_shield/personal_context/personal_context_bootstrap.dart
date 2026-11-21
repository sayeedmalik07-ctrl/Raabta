import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/outdated_brand_catalog.dart';

abstract final class PersonalContextBootstrap {
  static const _outdatedAsset = 'assets/scam_shield/outdated_names.json';

  static Future<void> loadOutdatedBrandCatalog() async {
    try {
      final raw = await rootBundle.loadString(_outdatedAsset);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entries = OutdatedBrandCatalog.parseEntriesJson(decoded);
      if (entries.isNotEmpty) {
        OutdatedBrandCatalog.applyEntries(entries);
      }
    } catch (_) {
      // bundled seed in core remains
    }
  }
}
