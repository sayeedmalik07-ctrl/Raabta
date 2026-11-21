import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Community hub modernization folders — tokens only (no raw hex or legacy cyan).
void main() {
  test('community presentation has no hardcoded Color(0x literals', () {
    final violations = <String>[];

    void scanFile(File file) {
      final relative = file.path.replaceAll('\\', '/');
      if (file.readAsStringSync().contains('Color(0x')) {
        violations.add(relative);
      }
    }

    const dirs = [
      'lib/screens/community',
      'lib/features/community',
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
      reason: 'Use AppColors / communityHubAccent tokens instead of raw hex in: $violations',
    );
  });

  test('community presentation does not use AppColors.purpleGlow', () {
    final violations = <String>[];

    for (final dirPath in const [
      'lib/screens/community',
      'lib/features/community',
    ]) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final content = entity.readAsStringSync();
        if (content.contains('AppColors.purpleGlow')) {
          violations.add(entity.path.replaceAll('\\', '/'));
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use brandFamily* / communityHubAccent for rumour chrome in: $violations',
    );
  });

  test('community presentation does not use AppColors.cyanGlow', () {
    final violations = <String>[];

    for (final dirPath in const [
      'lib/screens/community',
      'lib/features/community',
    ]) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final content = entity.readAsStringSync();
        if (content.contains('AppColors.cyanGlow')) {
          violations.add(entity.path.replaceAll('\\', '/'));
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use brandFamily* for chrome and communityHubAccent for social accents in: $violations',
    );
  });
}
