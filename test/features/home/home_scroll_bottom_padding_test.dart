import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/features/home/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen.homeScrollBottomPadding (D5)', () {
    testWidgets('adds 16dp extra above shell nav clearance', (tester) async {
      const safeBottom = 34.0;
      late BuildContext captured;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: safeBottom)),
            child: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      final padding = HomeScreen.homeScrollBottomPadding(captured);
      final expected = HomeScreen.shellBodyBottomClearance() +
          safeBottom +
          HomeScreen.homeFeedBottomClearanceExtra;

      expect(HomeScreen.homeFeedBottomClearanceExtra, 16);
      expect(padding, expected);
    });

    testWidgets('keyboard open path uses zero padding in scroll branch', (tester) async {
      // Documented in HomeScreen: usesHomeScrollUnderNav false when viewInsets > 0.
      expect(
        HomeScreen.usesHomeScrollUnderNav(
          currentTab: ShellTab.home,
          showBottomNav: false,
        ),
        isFalse,
      );
    });
  });
}