import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';

void main() {
  testWidgets('MarketplaceScreen shows hub error state when listings fail',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tester.view.physicalSize = const Size(390 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const locale = 'English';
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MarketplaceScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => locale),
          currentUserProvider.overrideWith((ref) => null),
          marketplaceListingsProvider.overrideWith(
            (ref) async => throw Exception('test'),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(
      find.text(MarketplaceStrings.t('mp_err_load_hub', locale)),
      findsOneWidget,
    );
    expect(
      find.text(CommonActionStrings.t('action_retry', locale)),
      findsOneWidget,
    );
  });
}
