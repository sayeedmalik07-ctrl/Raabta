import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
import 'package:raabta/features/home/widgets/home_truth_engine_reveal_listener.dart';

void main() {
  testWidgets('backgrounding hides revealed state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeTruthEngineRevealListener(
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeTruthEngineRevealListener)),
    );
    container.read(homeTruthEngineRevealControllerProvider).reveal();
    expect(container.read(homeTruthEngineDetailsRevealedProvider), isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(container.read(homeTruthEngineDetailsRevealedProvider), isFalse);
  });
}
