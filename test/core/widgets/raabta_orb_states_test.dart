import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';

void main() {
  testWidgets('RaabtaOrbStatePreview shows six states', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RaabtaOrbStatePreview(size: 48),
        ),
      ),
    );

    expect(find.byType(RaabtaOrb), findsNWidgets(RaabtaOrbState.values.length));
    for (final state in RaabtaOrbState.values) {
      expect(find.text(state.name), findsOneWidget);
    }
  });
}
