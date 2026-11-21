import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/home_truth_engine_reveal_controller.dart';

void main() {
  group('HomeTruthEngineRevealController', () {
    test('starts hidden by default', () {
      var notified = 0;
      final controller = HomeTruthEngineRevealController(
        onRevealedChanged: () => notified++,
      );
      addTearDown(controller.dispose);

      expect(controller.isRevealed, isFalse);
      expect(notified, 0);
    });

    test('reveal sets revealed and auto-hides after duration', () {
      var changeCount = 0;
      final pending = <(Duration, void Function())>[];
      final controller = HomeTruthEngineRevealController(
        onRevealedChanged: () => changeCount++,
        autoHideAfter: const Duration(seconds: 8),
        runAfter: (duration, callback) => pending.add((duration, callback)),
      );
      addTearDown(controller.dispose);

      controller.reveal();
      expect(controller.isRevealed, isTrue);
      expect(changeCount, 1);
      expect(pending, hasLength(1));
      expect(pending.single.$1, const Duration(seconds: 8));

      pending.single.$2();
      expect(controller.isRevealed, isFalse);
      expect(changeCount, 2);
    });

    test('toggle hides when already revealed', () {
      final controller = HomeTruthEngineRevealController(
        onRevealedChanged: () {},
        runAfter: (_, __) {},
      );
      addTearDown(controller.dispose);

      controller.reveal();
      controller.toggle();
      expect(controller.isRevealed, isFalse);
    });

    test('onAppBackgrounded and onRouteChanged hide', () {
      final controller = HomeTruthEngineRevealController(
        onRevealedChanged: () {},
        runAfter: (_, __) {},
      );
      addTearDown(controller.dispose);

      controller.reveal();
      controller.onAppBackgrounded();
      expect(controller.isRevealed, isFalse);

      controller.reveal();
      controller.onRouteChanged();
      expect(controller.isRevealed, isFalse);
    });

    test('reveal restarts auto-hide timer', () {
      final pending = <(Duration, void Function())>[];
      final controller = HomeTruthEngineRevealController(
        onRevealedChanged: () {},
        runAfter: (d, c) => pending.add((d, c)),
      );
      addTearDown(controller.dispose);

      controller.reveal();
      controller.reveal();
      expect(pending, hasLength(2));
    });
  });
}
