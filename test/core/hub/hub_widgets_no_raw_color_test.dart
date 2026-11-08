import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fails if new hardcoded `Color(0x` literals appear under hub widgets.
const _allowList = <String>{
  // Hub widgets must use AppColors / ColorFamily tokens only.
};

void main() {
  test('hub widget folder has no hardcoded Color(0x literals', () {
    final hubDir = Directory('lib/core/widgets/hub');
    expect(hubDir.existsSync(), isTrue);

    final violations = <String>[];
    for (final entity in hubDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relative = entity.path.replaceAll('\\', '/');
      if (_allowList.contains(relative)) continue;

      final content = entity.readAsStringSync();
      if (content.contains('Color(0x')) {
        violations.add(relative);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use AppColors tokens instead of raw hex in: $violations',
    );
  });
}
