import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/cooling_resource.dart';

/// Read-only cooling capabilities derived from repository evidence only.
///
/// Section comments match [CoolingResourcesCatalog] in
/// `cooling_resources_catalog.dart` (not inferred from venue names).
abstract final class CoolingResourceClassification {
  /// Catalog L7 — applies to all mall entries in that section.
  static const catalogMallSectionComment =
      'Major malls (air-conditioned)';

  /// Catalog L81 — applies to all metro entries in that section.
  static const catalogMetroSectionComment =
      'Doha Metro stations (air-conditioned)';

  /// Catalog L173 — applies to all hospital entries in that section.
  static const catalogHospitalSectionComment =
      'Hospitals (AC lobbies / waiting areas)';

  /// Catalog L222 — applies to all shaded_area entries in that section.
  static const catalogShadedSectionComment = 'Shaded outdoor parks';

  /// Provenance keys map to [ClimateStrings] (`cooling_prov_*`).
  static const provenanceCatalogMall = 'cooling_prov_catalog_mall';
  static const provenanceCatalogMetro = 'cooling_prov_catalog_metro';
  static const provenanceCatalogHospital = 'cooling_prov_catalog_hospital';
  static const provenanceCatalogShaded = 'cooling_prov_catalog_shaded';
  static const provenanceMosqueAc = 'cooling_prov_mosque_ac';

  /// Exact repository quotes documenting unrestricted public access.
  ///
  /// Hotel “guests and visitors” wording is excluded — not unrestricted public.
  static const publicAccessEvidenceByMosqueId = <String, String>{};

  static CoolingResource enrichCatalogEntry(CoolingResource resource) {
    if (resource.id.startsWith('places_')) {
      return resource;
    }

    var acRest = resource.acRest;
    var respite = resource.respite;
    String? provenanceKey = resource.classificationProvenanceKey;

    if (resource.id.startsWith('mall_') && resource.type == 'mall') {
      acRest = true;
      provenanceKey = provenanceCatalogMall;
    } else if (resource.id.startsWith('metro_') && resource.type == 'metro') {
      acRest = true;
      provenanceKey = provenanceCatalogMetro;
    } else if (resource.id.startsWith('hospital_') &&
        resource.type == 'hospital') {
      acRest = true;
      respite = true;
      provenanceKey = provenanceCatalogHospital;
    } else if (resource.type == 'shaded_area') {
      respite = true;
      provenanceKey = provenanceCatalogShaded;
    }

    return resource.copyWith(
      acRest: acRest,
      respite: respite,
      classificationProvenanceKey: provenanceKey,
    );
  }

  static CoolingResource enrichFromMosque(
    CoolingResource base,
    MosquePlace mosque,
  ) {
    final acRest = mosque.facilities.airConditioning;
    final publicQuote = publicAccessEvidenceByMosqueId[mosque.id];

    return base.copyWith(
      acRest: acRest,
      respite: false,
      classificationProvenanceKey:
          acRest ? provenanceMosqueAc : base.classificationProvenanceKey,
      publicAccessEvidence: publicQuote,
    );
  }

  static bool hasPublicAccessEvidence(CoolingResource resource) {
    return resource.publicAccessEvidence != null &&
        resource.publicAccessEvidence!.trim().isNotEmpty;
  }

  /// Nearest stop for guidance: classified + explicit public-access quote only.
  static CoolingResource? nearestPublicAccessStop(
    List<CoolingResource> resources,
  ) {
    final eligible = resources.where((r) {
      if (!hasPublicAccessEvidence(r)) return false;
      if (!r.acRest && !r.respite) return false;
      return r.distanceMeters != null;
    }).toList();

    if (eligible.isEmpty) return null;

    eligible.sort(
      (a, b) =>
          (a.distanceMeters ?? double.infinity)
              .compareTo(b.distanceMeters ?? double.infinity),
    );
    return eligible.first;
  }

  static List<CoolingResource> applyCapabilityFilter(
    List<CoolingResource> resources, {
    String? capabilityFilter,
  }) {
    if (capabilityFilter == null || capabilityFilter.isEmpty) {
      return resources;
    }
    switch (capabilityFilter) {
      case 'ac_rest':
        return resources.where((r) => r.acRest).toList();
      case 'respite':
        return resources.where((r) => r.respite).toList();
      default:
        return resources;
    }
  }
}
