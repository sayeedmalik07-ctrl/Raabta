import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

void main() {
  group('moneyHubRelativeUpdatedLabel', () {
    test('uses just-now string within 60 seconds', () {
      final clock = DateTime(2025, 6, 15, 12, 0);
      final updated = clock.subtract(const Duration(seconds: 30));
      final label = moneyHubRelativeUpdatedLabel(
        'English',
        updated,
        clock: clock,
      );
      expect(label, isNotEmpty);
      expect(label.toLowerCase(), contains('just'));
    });

    test('Arabic uses localized template for minutes', () {
      final clock = DateTime(2025, 6, 15, 12, 0);
      final updated = clock.subtract(const Duration(minutes: 5));
      final label = moneyHubRelativeUpdatedLabel(
        'Arabic',
        updated,
        clock: clock,
      );
      expect(label, contains('5'));
      expect(label, contains('تم التحديث'));
    });
  });
}
