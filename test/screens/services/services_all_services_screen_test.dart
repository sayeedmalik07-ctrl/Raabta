import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/data/service_front_groups.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/services_all_services_screen.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';

import 'services_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServicesAllServicesScreen', () {
    testWidgets('shows 12 front groups, search filters, tap pushes category',
        (tester) async {
      const locale = 'English';
      String? pushedCategoryId;

      final router = GoRouter(
        initialLocation: '/services/all',
        routes: [
          GoRoute(
            path: '/services/all',
            builder: (context, state) => const ServicesAllServicesScreen(),
          ),
          GoRoute(
            path: '/services/category/:categoryId',
            builder: (context, state) {
              pushedCategoryId = state.pathParameters['categoryId'];
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ],
      );

      tester.view.physicalSize = const Size(390 * 3, 2200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userLanguageProvider.overrideWith((ref) => locale),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(ServicesAllServicesScreen.screenKey), findsOneWidget);

      final firstLabel = ServiceFrontGroupLabels.labelEnglish(
        ServiceFrontGroupIds.orderedIds.first,
      )!;

      expect(find.text(firstLabel), findsOneWidget);
      expect(find.byType(ServiceSubcategoryTile), findsNWidgets(12));

      final searchField = find.byKey(const Key('services_all_services_search'));
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'zzzznomatchplz999');
      await tester.pump();

      expect(
        find.text(ServicesStrings.t('hub_all_services_no_groups', locale)),
        findsOneWidget,
      );

      await tester.enterText(searchField, '');
      await tester.pump();

      await tester.tap(find.text(firstLabel));
      await tester.pump();

      expect(pushedCategoryId, 'home_cleaning');
    });

    testWidgets('hub test helper pumps real All services route', (tester) async {
      await tester.pumpWidget(
        pumpServicesAllServicesScreen(tester: tester),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(ServicesAllServicesScreen.screenKey), findsOneWidget);
      expect(find.byType(ServiceSubcategoryTile), findsNWidgets(12));
    });
  });
}
