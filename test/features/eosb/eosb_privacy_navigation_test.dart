import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/eosb_dashboard_screen.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class _TestEosbNotifier extends EosbNotifier {
  _TestEosbNotifier(Ref ref)
    : super(const EosbCalculationService(), null, ref) {
    state = const EosbState();
  }
}

void main() {
  setUp(() => AppColors.applyBrightness(false));
  tearDown(() => AppColors.applyBrightness(false));

  testWidgets('EOSB hub security button opens profile privacy', (tester) async {
    final router = GoRouter(
      initialLocation: '/eosb',
      routes: [
        GoRoute(
          path: '/eosb',
          builder: (context, state) => const EosbDashboardScreen(),
        ),
        GoRoute(
          path: '/profile/privacy',
          builder: (context, state) =>
              const Scaffold(body: Text('privacy-screen')),
        ),
        GoRoute(
          path: '/eosb/settings',
          redirect: (context, state) => '/profile/privacy',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          eosbLocaleProvider.overrideWith((ref) async => 'English'),
          eosbProvider.overrideWith((ref) => _TestEosbNotifier(ref)),
        ],
        child: MaterialApp.router(
          theme: ThemeData(brightness: Brightness.dark),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.shield_outlined));
    await tester.pumpAndSettle();

    expect(find.text('privacy-screen'), findsOneWidget);
  });

  testWidgets('/eosb/settings redirects to privacy', (tester) async {
    final router = GoRouter(
      initialLocation: '/eosb/settings',
      routes: [
        GoRoute(
          path: '/eosb/settings',
          redirect: (context, state) => '/profile/privacy',
        ),
        GoRoute(
          path: '/profile/privacy',
          builder: (context, state) =>
              const Scaffold(body: Text('privacy-redirect')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(brightness: Brightness.dark),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('privacy-redirect'), findsOneWidget);
  });

  test('hub tooltip uses eosb_privacy_security string', () {
    expect(
      EosbStrings.t('eosb_privacy_security', 'English'),
      'Privacy & security',
    );
  });
}
