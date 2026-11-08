import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_providers.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/features/scam_shield/presentation/screens/family_verification_kit_screen.dart';

void main() {
  group('FamilyVerificationKitStrings Batch 1 keys', () {
    const keys = [
      'ss_fvk_kit_subtitle',
      'ss_fvk_prefs_load_error_title',
      'ss_fvk_prefs_load_error_body',
      'ss_fvk_prefs_retry',
    ];

    test('non-empty for all nine locales', () {
      for (final key in keys) {
        for (final locale in AppLocale.supportedLocales) {
          expect(
            FamilyVerificationKitStrings.t(key, locale),
            isNotEmpty,
            reason: '$key / $locale',
          );
        }
      }
    });

    test('non-English differs from English for explicit keys', () {
      for (final key in keys) {
        final english = FamilyVerificationKitStrings.t(key, 'English');
        for (final locale in AppLocale.supportedLocales) {
          if (locale == 'English') continue;
          expect(
            FamilyVerificationKitStrings.t(key, locale),
            isNot(equals(english)),
            reason: '$key / $locale',
          );
        }
      }
    });
  });

  group('FamilyVerificationKitScreen', () {
    testWidgets('shows loading placeholders while prefs loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyVerificationPrefsProvider.overrideWith(
              (ref) => Completer<FamilyVerificationPrefs>().future,
            ),
          ],
          child: const MaterialApp(home: FamilyVerificationKitScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('shows error empty state with retry when prefs fail', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyVerificationPrefsProvider.overrideWith(
              (ref) async => throw Exception('prefs'),
            ),
          ],
          child: const MaterialApp(home: FamilyVerificationKitScreen()),
        ),
      );
      // HubSubscreenScaffold uses AnimatedAuroraBackground — avoid pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text(
          FamilyVerificationKitStrings.t('ss_fvk_prefs_load_error_title', 'English'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(FamilyVerificationKitStrings.t('ss_fvk_prefs_retry', 'English')),
        findsOneWidget,
      );
    });
  });
}
