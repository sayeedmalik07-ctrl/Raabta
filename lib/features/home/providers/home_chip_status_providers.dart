import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/domain/home_chip_status_logic.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_storage.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Lazy per-route status for Home chips — only watched when a chip is built.
final homeChipStatusProvider =
    FutureProvider.family<HomeChipStatus, String>((ref, route) async {
  final locale = ref.watch(userLanguageProvider);

  try {
    switch (route) {
      case '/eosb':
        final history = await ref.watch(eosbHistoryProvider.future);
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          eosbHasSavedEstimate: history.isNotEmpty,
        );
      case '/tenancy':
        final repo = await ref.watch(tenancyRepositoryProvider.future);
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          tenancyCheckCompleted: repo.hasCompletedCheck(),
        );
      case '/health-insurance':
        final repo = await ref.watch(healthInsuranceRepositoryProvider.future);
        final checkedAt = repo.loadCachedResult()?.checkedAt;
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          healthPolicyChecked: checkedAt != null,
        );
      case '/warranty-shield':
        final uid = ref.read(currentAuthUidProvider);
        final items = await WarrantyStorage.load(uid: uid);
        final expiring =
            items.where((WarrantyItem w) => w.expiringsSoon).length;
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          warrantyExpiringCount: expiring,
        );
      case '/climate-navigator':
        final weather = await ref.watch(qatarWeatherProvider.future);
        final valid = weather.dataAvailable && !weather.isFallback;
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          heatDataValid: valid,
          heatRiskLevelKey: valid ? weather.wbgtRiskLevelKey : null,
        );
      case '/trip-planner':
        final repo = await ref.watch(tripPlannerRepositoryProvider.future);
        final trips = await repo.loadTrips();
        final tripTitle = _tripTitleForHome(repo.getActiveTripId(), trips);
        return HomeChipStatusLogic.forRoute(
          route: route,
          locale: locale,
          tripTitle: tripTitle,
        );
      default:
        return HomeChipStatusLogic.forRoute(route: route, locale: locale);
    }
  } catch (_) {
    return HomeChipStatusLogic.forRoute(route: route, locale: locale);
  }
});

String? _tripTitleForHome(String? activeId, List<TripPlan> trips) {
  if (trips.isEmpty) return null;
  if (activeId != null) {
    for (final trip in trips) {
      if (trip.id == activeId) return trip.title;
    }
  }
  return trips.first.title;
}

/// Maps [AsyncValue] from [homeChipStatusProvider] to a [HomeChipStatus] for UI.
HomeChipStatus watchHomeChipStatus(WidgetRef ref, String route, String locale) {
  final async = ref.watch(homeChipStatusProvider(route));
  return async.when(
    loading: () => const HomeChipStatus.loading(),
    error: (_, _) =>
        HomeChipStatusLogic.forRoute(route: route, locale: locale),
    data: (status) => status,
  );
}

String homeChipAccessibilityLabel({
  required String title,
  required HomeChipStatus status,
}) {
  if (status.isLoading || status.line.isEmpty) return title;
  return '$title, ${status.line}';
}
