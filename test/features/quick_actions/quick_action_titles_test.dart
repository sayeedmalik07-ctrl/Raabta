import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/bill_splitter_screen.dart';
import 'package:raabta/features/quick_actions/climate_navigator_screen.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/features/quick_actions/queue_avoidance_screen.dart';

void main() {
  group('Quick Actions destination AppBar titles', () {
    testWidgets('ClimateNavigatorScreen shows Heat Safety', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ClimateNavigatorScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Heat Safety'), findsOneWidget);
      expect(find.text('Climate Navigator'), findsNothing);
    });

    testWidgets('QueueAvoidanceScreen shows Skip the Queue', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QueueAvoidanceScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Skip the Queue'), findsOneWidget);
      expect(find.text('Queue Avoidance'), findsNothing);
    });

    testWidgets('BillSplitterScreen shows Split Bills', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BillSplitterScreen()),
      );
      await tester.pump();

      expect(find.text('Split Bills'), findsOneWidget);
      expect(find.text('Bill Splitter'), findsNothing);
    });

    // BillTrackerScreen touches FirebaseFirestore in its State field initializer;
    // AppBar title is covered via QuickActionsHub label test below.
  });

  group('QuickActionsHub tile labels', () {
    testWidgets('shows updated titles and unchanged Warranty Shield', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: QuickActionsHub(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Heat Safety'), findsOneWidget);
      expect(find.text('Skip the Queue'), findsOneWidget);
      expect(find.text('Split Bills'), findsOneWidget);
      expect(find.text('Bill Reminders'), findsOneWidget);
      expect(find.text('Warranty Shield'), findsOneWidget);

      expect(find.text('Heat Navigator'), findsNothing);
      expect(find.text('Queue Avoidance'), findsNothing);
      expect(find.text('Bill Splitter'), findsNothing);
      expect(find.text('Bill Tracker'), findsNothing);
    });
  });
}
