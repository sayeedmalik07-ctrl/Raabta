import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/home/utils/home_ai_assistant_launcher.dart';
void main() {
  tearDown(HomeAiAssistantLauncher.resetDebounceForTest);

  testWidgets('debounces duplicate navigations within 600 ms', (tester) async {
    HomeAiAssistantLauncher.resetDebounceForTest();
    var pushCount = 0;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/ai-chat',
          builder: (_, state) {
            pushCount++;
            return const Scaffold(body: Text('ai-chat'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );

    final context = tester.element(find.byType(SizedBox));
    expect(
      HomeAiAssistantLauncher.open(context, query: 'hint'),
      isTrue,
    );
    await tester.pump();
    expect(pushCount, 1);

    expect(
      HomeAiAssistantLauncher.open(context, query: 'hint'),
      isFalse,
    );
    await tester.pump();
    expect(pushCount, 1);
  });
}
