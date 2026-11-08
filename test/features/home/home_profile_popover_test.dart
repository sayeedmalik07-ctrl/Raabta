import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/widgets/home_brand_primary_button.dart';
import 'package:raabta/features/home/widgets/home_profile_popover.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

void main() {
  testWidgets('guest popover shows sign in and hides sign out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          userLanguageProvider.overrideWith((ref) => 'English'),
          resolvedAuthUserForProfileProvider.overrideWith(
            (ref) async => null,
          ),
          isPremiumUserProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: buildHomeProfilePopoverPanelForTest(
              onClose: () {},
              onShortcut: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HomeBrandPrimaryButton), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });
}
