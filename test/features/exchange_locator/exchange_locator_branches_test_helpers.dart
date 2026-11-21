import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/exchange_locator/domain/exchange_queue_logic.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_review.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_panel.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kBranchesTestLocale = 'English';

/// Configurable fake — no Firebase, Firestore, or network.
class FakeExchangeLocatorRepository implements ExchangeLocatorRepository {
  FakeExchangeLocatorRepository({
    this.companiesException,
    this.failCompaniesFetchTimes = 0,
  });

  final Object? companiesException;
  final int failCompaniesFetchTimes;

  int companiesFetchCount = 0;

  @override
  Future<PaginatedResult<ExchangeCompany>> fetchCompanies({
    int limit = 20,
    String? startAfterId,
    bool featuredOnly = false,
  }) async {
    companiesFetchCount++;
    if (companiesException != null &&
        companiesFetchCount <= failCompaniesFetchTimes) {
      throw companiesException!;
    }
    return const PaginatedResult<ExchangeCompany>(items: [], hasMore: false);
  }

  @override
  Future<ExchangeCompany?> fetchCompany(String companyId) async => null;

  @override
  Future<PaginatedResult<ExchangeBranch>> fetchBranches({
    int limit = 30,
    String? startAfterId,
    String? companyId,
    BranchFinderFilters? filters,
  }) async {
    return const PaginatedResult<ExchangeBranch>(items: [], hasMore: false);
  }

  @override
  Future<ExchangeBranch?> fetchBranch(String branchId) async => null;

  @override
  Future<List<ExchangeBranch>> fetchAllBranchesForMap() async => const [];

  @override
  Future<List<ExchangeBranch>> refreshBranchesForMap() async => const [];

  @override
  Future<PaginatedResult<ExchangeReview>> fetchReviews({
    required String branchId,
    int limit = 15,
    String? startAfterId,
    ExchangeReviewSort sort = ExchangeReviewSort.recent,
  }) async {
    return const PaginatedResult<ExchangeReview>(items: [], hasMore: false);
  }

  @override
  Future<bool> hasUserReviewedBranch({
    required String branchId,
    required String userId,
  }) async =>
      false;

  @override
  Future<void> submitReview({
    required String branchId,
    required String userId,
    required int rating,
    required String review,
    String? userDisplayName,
  }) async {}

  @override
  Stream<Set<String>> watchFavoriteBranchIds(String userId) async* {
    yield {};
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String branchId,
    required ExchangeBranch branch,
  }) async {}

  @override
  Future<List<ExchangeBranch>> fetchFavoriteBranches(String userId) async =>
      [];

  @override
  Future<List<CrowdReportSample>> fetchRecentCrowdReports(
    String branchId,
  ) async =>
      [];

  @override
  Future<void> submitCrowdReport({
    required String branchId,
    required String userId,
    required CrowdReportLevel level,
  }) async {}

  @override
  Future<void> recordRecentVisitRemote({
    required String userId,
    required ExchangeBranch branch,
  }) async {}

  @override
  Future<List<ExchangeBranch>> fetchRecentVisitsRemote(String userId) async =>
      [];

  @override
  Future<void> setBranchDetailsVerified({
    required String branchId,
    required bool verified,
  }) async {}

  @override
  Future<String> upsertCompany(ExchangeCompany company) async => company.id;

  @override
  Future<void> deleteCompany(String companyId) async {}

  @override
  Future<String> upsertBranch(ExchangeBranch branch) async => branch.id;

  @override
  Future<void> deleteBranch(String branchId) async {}

  @override
  Future<void> syncBranchServices(String branchId, List<String> services) async {}
}

class FakePrayerLocationService extends PrayerLocationService {
  @override
  Future<bool> ensurePermission() async => false;
}

void configureBranchesTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
}

List<Override> defaultLocatorProviderOverrides({
  FakeExchangeLocatorRepository? repository,
  List<Override> extra = const [],
}) {
  final repo = repository ?? FakeExchangeLocatorRepository();

  return [
    userLanguageProvider.overrideWith((ref) => kBranchesTestLocale),
    currentUserProvider.overrideWith((ref) => null),
    exchangeLocatorRepositoryProvider.overrideWith((ref) async => repo),
    exchangeLocatorLocationServiceProvider.overrideWith(
      (ref) => FakePrayerLocationService(),
    ),
    favoriteBranchIdsProvider.overrideWith((ref) => Stream.value({})),
    favoriteBranchesProvider.overrideWith((ref) async => []),
    recentVisitsProvider.overrideWith((ref) async => []),
    ...extra,
  ];
}

Future<void> pumpExchangeLocatorPanel(
  WidgetTester tester, {
  int initialTab = 0,
  FakeExchangeLocatorRepository? repository,
  List<Override> extraOverrides = const [],
  Widget? child,
}) async {
  configureBranchesTestEnvironment();

  tester.view.physicalSize = const Size(390 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final overrides = defaultLocatorProviderOverrides(
    repository: repository,
    extra: extraOverrides,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 900,
            child: child ?? ExchangeLocatorPanel(initialTab: initialTab),
          ),
        ),
      ),
    ),
  );
}

/// Bounded settle — avoids hanging on map [HubLoadingPlaceholder] animations.
Future<void> settleLocatorContent(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump();
}

/// Drives [ExchangeLocatorPanel.didUpdateWidget] via [initialTab] changes.
class LocatorTabHarness extends StatefulWidget {
  const LocatorTabHarness({super.key, required this.tabListenable});

  final ValueNotifier<int> tabListenable;

  @override
  State<LocatorTabHarness> createState() => _LocatorTabHarnessState();
}

class _LocatorTabHarnessState extends State<LocatorTabHarness> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.tabListenable,
      builder: (context, tab, _) {
        return ExchangeLocatorPanel(initialTab: tab);
      },
    );
  }
}
