import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/cooling_resource_classification.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/cooling_resources_catalog.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/cooling_resource.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/cooling_resources_service.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/cooling_resources_panel.dart';

void main() {
  const dohaLat = 25.2854;
  const dohaLng = 51.5310;

  group('catalog classifications', () {
    test('mall entry gets ac_rest from section evidence only', () {
      final raw = CoolingResourcesCatalog.verified
          .firstWhere((r) => r.id == 'mall_city_center');
      final enriched = CoolingResourceClassification.enrichCatalogEntry(raw);
      expect(enriched.acRest, isTrue);
      expect(enriched.respite, isFalse);
      expect(
        enriched.classificationProvenanceKey,
        CoolingResourceClassification.provenanceCatalogMall,
      );
    });

    test('hospital gets ac_rest and respite', () {
      final raw = CoolingResourcesCatalog.verified
          .firstWhere((r) => r.id == 'hospital_hamad_general');
      final enriched = CoolingResourceClassification.enrichCatalogEntry(raw);
      expect(enriched.acRest, isTrue);
      expect(enriched.respite, isTrue);
    });

    test('shaded park gets respite only', () {
      final raw =
          CoolingResourcesCatalog.verified.firstWhere((r) => r.id == 'park_aspire');
      final enriched = CoolingResourceClassification.enrichCatalogEntry(raw);
      expect(enriched.acRest, isFalse);
      expect(enriched.respite, isTrue);
    });

    test('library stays unclassified', () {
      final raw =
          CoolingResourcesCatalog.verified.firstWhere((r) => r.id == 'library_qnl');
      final enriched = CoolingResourceClassification.enrichCatalogEntry(raw);
      expect(enriched.acRest, isFalse);
      expect(enriched.respite, isFalse);
      expect(enriched.classificationProvenanceKey, isNull);
    });
  });

  group('mosque propagation', () {
    test('airConditioning true sets ac_rest', () {
      const mosque = MosquePlace(
        id: 'state_grand_mosque',
        name: 'State Grand Mosque',
        latitude: 25.3167,
        longitude: 51.5300,
        address: 'Doha',
        facilities: MosqueFacilities(airConditioning: true),
      );
      final base = CoolingResource(
        id: mosque.id,
        name: mosque.name,
        type: 'mosque',
        latitude: mosque.latitude,
        longitude: mosque.longitude,
      );
      final enriched =
          CoolingResourceClassification.enrichFromMosque(base, mosque);
      expect(enriched.acRest, isTrue);
      expect(enriched.classificationProvenanceKey,
          CoolingResourceClassification.provenanceMosqueAc);
    });

    test('airConditioning false leaves ac_rest off', () {
      const mosque = MosquePlace(
        id: 'souq_waqif_mosque',
        name: 'Souq Waqif Mosque',
        latitude: 25.2889,
        longitude: 51.5328,
        address: 'Souq Waqif',
        facilities: MosqueFacilities(airConditioning: false, ablution: true),
      );
      final base = CoolingResource(
        id: mosque.id,
        name: mosque.name,
        type: 'mosque',
        latitude: mosque.latitude,
        longitude: mosque.longitude,
      );
      final enriched =
          CoolingResourceClassification.enrichFromMosque(base, mosque);
      expect(enriched.acRest, isFalse);
      expect(enriched.publicAccessEvidence, isNull);
    });

    test('sheraton keeps ac_rest but no nearest-stop public access evidence', () {
      const mosque = MosquePlace(
        id: 'sheraton_prayer',
        name: 'Sheraton Grand Doha Prayer Room',
        latitude: 25.3193,
        longitude: 51.5361,
        address: 'West Bay',
        description: 'Hotel prayer room for guests and visitors.',
        facilities: MosqueFacilities(airConditioning: true),
      );
      final base = CoolingResource(
        id: mosque.id,
        name: mosque.name,
        type: 'mosque',
        latitude: mosque.latitude,
        longitude: mosque.longitude,
      );
      final enriched =
          CoolingResourceClassification.enrichFromMosque(base, mosque);
      expect(enriched.acRest, isTrue);
      expect(enriched.publicAccessEvidence, isNull);
    });
  });

  group('service integration', () {
    final service = CoolingResourcesService();

    test('verifiedNearby applies capability filter ac_rest', () {
      final all = service.verifiedNearby(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
      );
      final acOnly = service.verifiedNearby(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
        capabilityFilter: 'ac_rest',
      );
      expect(acOnly, isNotEmpty);
      expect(acOnly.every((r) => r.acRest), isTrue);
      expect(acOnly.length, lessThan(all.length));
    });

    test('distance uses haversine via distanceMeters', () {
      final list = service.verifiedNearby(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
      );
      final msheireb = list.firstWhere((r) => r.id == 'metro_msheireb');
      final expectedM = PrayerLocationService.haversineKm(
            dohaLat,
            dohaLng,
            msheireb.latitude,
            msheireb.longitude,
          ) *
          1000;
      expect(msheireb.distanceMeters, closeTo(expectedM, 1));
    });

    test('nearest public stop null when no unrestricted public access ids', () {
      final nearest = service.nearestPublicAccessStop(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
      );
      expect(nearest, isNull);
    });

    test('nearest public stop empty when no access quotes in radius', () {
      final onlyMall = service.nearestPublicAccessStop(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
        typeFilter: 'mall',
      );
      expect(onlyMall, isNull);
    });

    test('empty capability filter yields no classified rows', () {
      final respiteOnly = service.verifiedNearby(
        latitude: dohaLat,
        longitude: dohaLng,
        radiusKm: 60,
        typeFilter: 'library',
        capabilityFilter: 'respite',
      );
      expect(respiteOnly, isEmpty);
    });
  });

  group('walk time approximation', () {
    test('estimateWalkMinutes not routed ETA', () {
      const km = 2.5;
      final minutes = PrayerLocationService.estimateWalkMinutes(km);
      expect(minutes, greaterThan(0));
      expect(minutes, (km / 5 * 60).ceil());
    });
  });

  group('localization', () {
    test('new cooling keys cover all nine locales', () {
      const keys = [
        'cooling_tag_ac_rest',
        'cooling_tag_respite',
        'cooling_cap_filter_all',
        'cooling_prov_catalog_mall',
        'cooling_prov_catalog_metro',
        'cooling_prov_catalog_hospital',
        'cooling_prov_catalog_shaded',
        'cooling_prov_mosque_ac',
        'cooling_nearest_stop_title',
        'cooling_nearest_walk_approx',
        'cooling_public_access_note',
        'cooling_detail_heading',
      ];
      for (final locale in AppLocale.supportedLocales) {
        for (final key in keys) {
          final value = ClimateStrings.t(key, locale);
          expect(value, isNotEmpty);
          expect(value, isNot(key));
        }
      }
    });

    test('walk label formats minutes param', () {
      final label = ClimateStrings.format(
        'cooling_nearest_walk_approx',
        'Arabic',
        params: {'minutes': '12'},
      );
      expect(label, contains('12'));
    });
  });

  group('nearest-stop location gate', () {
    test('does not offer guidance on Doha fallback (permission denied)', () {
      expect(
        CoolingResourcesPanel.shouldOfferNearestPublicStop(
          usingDeviceLocation: false,
          stop: const CoolingResource(
            id: 'mall_city_center',
            name: 'City Center Doha',
            type: 'mall',
            latitude: 25.3252,
            longitude: 51.5304,
            acRest: true,
            publicAccessEvidence: 'would-not-happen',
            distanceMeters: 100,
          ),
        ),
        isFalse,
      );
    });

    test('offers guidance only with device location and eligible stop', () {
      expect(
        CoolingResourcesPanel.shouldOfferNearestPublicStop(
          usingDeviceLocation: true,
          stop: null,
        ),
        isFalse,
      );
      expect(
        CoolingResourcesPanel.shouldOfferNearestPublicStop(
          usingDeviceLocation: true,
          stop: const CoolingResource(
            id: 'test',
            name: 'Test',
            type: 'mall',
            latitude: 1,
            longitude: 1,
            acRest: true,
            publicAccessEvidence: 'Public park.',
            distanceMeters: 50,
          ),
        ),
        isTrue,
      );
    });
  });

  group('RTL capability tags', () {
    testWidgets('tags lay out under RTL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Wrap(
                children: [
                  Chip(
                    label: Text(
                      ClimateStrings.t('cooling_tag_ac_rest', 'Arabic'),
                    ),
                  ),
                  Chip(
                    label: Text(
                      ClimateStrings.t('cooling_tag_respite', 'Arabic'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('راحة'), findsWidgets);
    });
  });
}
