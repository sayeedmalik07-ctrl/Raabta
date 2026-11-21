import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/widgets/home_language_toggle_chip.dart';
import 'package:raabta/providers/visa_providers.dart';

void main() {
  testWidgets('language pill is 44px tall with stable width', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HomeLanguageToggleChip(),
          ),
        ),
      ),
    );

    final pill = tester.getSize(find.byKey(const Key('home_language_pill')));
    expect(pill.height, 44);
    expect(pill.width, HomeLanguageToggleChip.pillWidth);
  });
}
