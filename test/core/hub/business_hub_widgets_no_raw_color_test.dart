import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('business hub folders have no hardcoded Color(0x literals', () {
    final hubFiles = [
      'lib/core/widgets/hub/hub_business_card.dart',
      'lib/core/widgets/hub/hub_detail_action_bar.dart',
      'lib/core/widgets/hub/hub_notice_banner.dart',
    ];

    final violations = <String>[];

    void scanFile(File file) {
      final relative = file.path.replaceAll('\\', '/');
      if (file.readAsStringSync().contains('Color(0x')) {
        violations.add(relative);
      }
    }

    for (final path in hubFiles) {
      final file = File(path);
      if (file.existsSync()) scanFile(file);
    }

    final businessesDir = Directory('lib/screens/businesses');
    if (businessesDir.existsSync()) {
      for (final entity in businessesDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          scanFile(entity);
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use AppColors tokens instead of raw hex in: $violations',
    );
  });
}
