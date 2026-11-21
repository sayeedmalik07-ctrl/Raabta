import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/providers/home_doha_day_part_provider.dart';
import 'package:raabta/features/home/widgets/home_doha_collapsing_header.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

HomeDohaHeaderConfig _config({required VoidCallback onDiscover}) {
  return (
    locale: 'English',
    greetingLine: 'Hello',
    profileInitials: 'R',
    showGuestProfileIcon: false,
    profilePhotoUrl: null,
    notificationCount: 0,
    onProfileTap: () {},
    onNotificationTap: () {},
    onDiscoverQatar: onDiscover,
    profileMenuSemanticsLabel: 'Profile',
    notificationSemanticsLabel: 'Notifications',
    searchRow: const SizedBox(height: 46, child: Text('search')),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    homeDohaDayPartDebugOverride = DohaDayPart.day;
  });

  tearDown(() {
    homeDohaDayPartDebugOverride = null;
  });

  test('KnowQatarScreen.route is the default hub path', () {
    expect(KnowQatarScreen.route(), '/know-qatar');
  });

  testWidgets('homeDohaOpenKnowQatar pushes KnowQatarScreen.route', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => homeDohaOpenKnowQatar(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/know-qatar',
          builder: (_, __) => const Scaffold(body: Text('know-qatar-screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('know-qatar-screen'), findsOneWidget);
  });

  testWidgets('Discover chip tap invokes navigation callback', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: HomeDohaTopZone.test(
              progress: 0,
              topSafeInset: 44,
              config: _config(onDiscover: () => tapped++),
              layersAvailable: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final label = KnowQatarStrings.t('kq_screen_title', 'English');
    await tester.tap(find.text(label));
    expect(tapped, 1);
  });

  testWidgets('RTL keeps chip semantics and min height', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: HomeDohaTopZone.test(
                progress: 0,
                topSafeInset: 44,
                config: _config(onDiscover: () {}),
                layersAvailable: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final label = KnowQatarStrings.t('kq_screen_title', 'English');
    final chip = tester.getSize(find.bySemanticsLabel(label));
    expect(chip.height, greaterThanOrEqualTo(44));
  });
}