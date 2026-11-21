import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/home_ai_orb_coach_mark_prefs.dart';
import 'package:raabta/features/home/widgets/home_ai_orb_coach_mark.dart';
import 'package:raabta/features/home/widgets/home_floating_ai_assistant.dart';
import 'package:raabta/features/home/widgets/home_floating_search_bar.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget hostHarness({
    required bool linkLeaderOnStickyRow,
    required Widget Function(BuildContext, HomeAiSearchOrbs) body,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: HomeAiAssistantHost(
            locale: 'English',
            active: true,
            showProactiveDot: false,
            orbLayerLink: LayerLink(),
            linkLeaderOnStickyRow: linkLeaderOnStickyRow,
            child: body,
          ),
        ),
      ),
    );
  }

  testWidgets('builds separate inline and sticky orbs', (tester) async {
    await tester.pumpWidget(
      hostHarness(
        linkLeaderOnStickyRow: false,
        body: (context, orbs) => Column(
          children: [
            HomeSearchWithAiRow(
              search: const Text('search'),
              aiOrb: orbs.inline,
            ),
            HomeFloatingSearchBar(
              visible: false,
              searchEntry: const Text('sticky search'),
              aiOrb: orbs.sticky,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeAliveAiOrb), findsNWidgets(2));
    expect(find.byKey(const Key('home_ai_orb_inline')), findsOneWidget);
    expect(find.byKey(const Key('home_ai_orb_sticky')), findsOneWidget);
  });

  testWidgets('exactly one CompositedTransformTarget when inline is leader',
      (tester) async {
    await tester.pumpWidget(
      hostHarness(
        linkLeaderOnStickyRow: false,
        body: (context, orbs) => Row(
          children: [orbs.inline!, orbs.sticky!],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CompositedTransformTarget), findsOneWidget);
  });

  testWidgets('exactly one CompositedTransformTarget when sticky is leader',
      (tester) async {
    await tester.pumpWidget(
      hostHarness(
        linkLeaderOnStickyRow: true,
        body: (context, orbs) => Row(
          children: [orbs.inline!, orbs.sticky!],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CompositedTransformTarget), findsOneWidget);
  });

  testWidgets('layer leader switches when sticky visibility toggles',
      (tester) async {
    var stickyLeader = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HomeAiAssistantHost(
                  locale: 'English',
                  active: true,
                  showProactiveDot: false,
                  orbLayerLink: LayerLink(),
                  linkLeaderOnStickyRow: stickyLeader,
                  child: (context, orbs) => Column(
                    children: [
                      orbs.inline!,
                      TextButton(
                        onPressed: () =>
                            setState(() => stickyLeader = !stickyLeader),
                        child: const Text('toggle'),
                      ),
                      orbs.sticky!,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CompositedTransformTarget), findsOneWidget);

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.byType(CompositedTransformTarget), findsOneWidget);
  });

  testWidgets('sticky search bar keeps orb subtree when collapsed', (tester) async {
    await tester.pumpWidget(
      hostHarness(
        linkLeaderOnStickyRow: true,
        body: (context, orbs) => HomeFloatingSearchBar(
          visible: false,
          searchEntry: const Text('search'),
          aiOrb: orbs.sticky,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeAliveAiOrb), findsOneWidget);
  });

  testWidgets('coach mark can anchor when inline orb is leader', (tester) async {
    final link = LayerLink();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                HomeAiAssistantHost(
                  locale: 'English',
                  active: true,
                  showProactiveDot: false,
                  orbLayerLink: link,
                  linkLeaderOnStickyRow: false,
                  child: (context, orbs) => orbs.inline!,
                ),
                HomeAiOrbCoachMark(
                  link: link,
                  locale: 'English',
                  visible: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('home_ai_orb_coach_mark')), findsOneWidget);
    expect(await HomeAiOrbCoachMarkPrefs.isDismissed(), isFalse);
  });
}
