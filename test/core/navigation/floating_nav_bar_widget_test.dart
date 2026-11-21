import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/navigation/floating_nav_bar.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';

void main() {
  testWidgets('FloatingNavBar builds without ticker errors', (tester) async {
    var tab = ShellTab.home;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingNavBar(
                    currentTab: tab,
                    slots: ShellNavConfig.slotsFor('English'),
                    locale: 'English',
                    postMenuOpen: false,
                    onPostMenuToggle: () {},
                    onTabSelected: (next) => tab = next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('shell_post_nav_button')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Market'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
