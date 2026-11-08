import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/navigation/shell_chrome_scope.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';

void main() {
  testWidgets('hubPostFabWhenAllowed hidden under shell chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ShellChromeScope(
          shellBottomNavVisible: true,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: const SizedBox.shrink(),
                floatingActionButton: hubPostFabWhenAllowed(
                  context,
                  onPressed: () {},
                  tooltip: 'Post',
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(HubPostFab), findsNothing);
  });

  testWidgets('hubPostFabWhenAllowed shown without shell chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: const SizedBox.shrink(),
              floatingActionButton: hubPostFabWhenAllowed(
                context,
                onPressed: () {},
                tooltip: 'Post',
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(HubPostFab), findsOneWidget);
  });
}
