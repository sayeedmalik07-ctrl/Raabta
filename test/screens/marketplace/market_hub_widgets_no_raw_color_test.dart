import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Market hub folders — no raw hex colors (tokens only per HUB_DESIGN_CONTRACT).
void main() {
  test('market hub presentation has no hardcoded Color(0x literals', () {
    final violations = <String>[];

    void scanFile(File file) {
      final relative = file.path.replaceAll('\\', '/');
      if (file.readAsStringSync().contains('Color(0x')) {
        violations.add(relative);
      }
    }

    const dirs = [
      'lib/screens/marketplace',
      'lib/features/marketplace',
    ];
    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          scanFile(entity);
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use AppColors / RaabtaColorFamilies tokens instead of raw hex in: $violations',
    );
  });
}
