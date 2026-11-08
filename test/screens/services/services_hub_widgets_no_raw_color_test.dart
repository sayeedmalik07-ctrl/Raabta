import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Services hub modernization folders — no raw hex colors.
void main() {
  test('services hub screens have no hardcoded Color(0x literals', () {
    final violations = <String>[];

    void scanFile(File file) {
      final relative = file.path.replaceAll('\\', '/');
      if (file.readAsStringSync().contains('Color(0x')) {
        violations.add(relative);
      }
    }

    final hubServiceCard = File('lib/core/widgets/hub/hub_service_card.dart');
    if (hubServiceCard.existsSync()) scanFile(hubServiceCard);

    final servicesDir = Directory('lib/screens/services');
    if (servicesDir.existsSync()) {
      for (final entity in servicesDir.listSync(recursive: true)) {
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
