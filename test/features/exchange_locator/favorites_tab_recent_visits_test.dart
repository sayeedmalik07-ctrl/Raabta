import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/favorites_tab.dart';

import 'exchange_locator_branches_test_helpers.dart';

void main() {
  testWidgets('recent visits error shows retry and re-fetches on tap',
      (tester) async {
    configureBranchesTestEnvironment();

    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var recentFetchAttempts = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...defaultLocatorProviderOverrides(),
          recentVisitsProvider.overrideWith((ref) async {
            recentFetchAttempts++;
            throw Exception('recent-fail');
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 900,
              child: FavoritesTab(),
            ),
          ),
        ),
      ),
    );
    await settleLocatorContent(tester);

    expect(find.textContaining('recent-fail'), findsOneWidget);
    expect(recentFetchAttempts, 1);

    final errorStates = find.byType(GlassErrorState);
    expect(errorStates, findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await settleLocatorContent(tester);

    expect(recentFetchAttempts, greaterThanOrEqualTo(2));
    expect(find.textContaining('recent-fail'), findsOneWidget);
  });
}
