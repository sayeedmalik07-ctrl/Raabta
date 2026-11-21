import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Visa & Documents presentation — no hardcoded Color(0x literals (tokens only).
void main() {
  test('visahelp presentation has no hardcoded Color(0x literals', () {
    final violations = <String>[];

    /// Legacy scanner demo still uses inline hex (not Batch D scope).
    const allowList = <String>{
      'lib/screens/visahelp/document_scan_screen.dart',
    };

    void scanFile(File file) {
      final relative = file.path.replaceAll('\\', '/');
      if (allowList.contains(relative)) return;
      if (file.readAsStringSync().contains('Color(0x')) {
        violations.add(relative);
      }
    }

    const dirs = [
      'lib/screens/visahelp',
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
      reason:
          'Use AppColors / RaabtaColorFamilies tokens instead of raw hex in: $violations',
    );
  });
}
