import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/widgets/profile_avatar.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

void main() {
  group('ProfileAvatar guest icon', () {
    testWidgets('signed-out shows person icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              initials: 'R',
              showGuestProfileIcon: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('R'), findsNothing);
    });

    testWidgets('signed-in shows initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(initials: 'MS'),
          ),
        ),
      );
      expect(find.text('MS'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
    });
  });

  test('trip day titles use singular for one day', () {
    expect(
      formatTripDaysInDestination(1, 'Doha', 'English'),
      '1 day in Doha',
    );
    expect(
      formatTripDaysInDestination(2, 'Doha', 'English'),
      '2 days in Doha',
    );
  });
}