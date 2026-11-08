import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';
import 'package:raabta/screens/visahelp/visa_home_screen.dart';
import 'package:raabta/features/legal_sources/providers/legal_sources_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visa hub landing builds with empty deadlines', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          lastLegalUpdateProvider.overrideWith(
            (ref) async => DateTime(2024, 6, 1),
          ),
          documentDeadlinesProvider.overrideWith(
            (ref) => Stream<List<DocumentDeadline>>.value(const []),
          ),
        ],
        child: const MaterialApp(
          home: VisaHomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.text(VisaStrings.t('visa_hub_title', 'English')),
      findsOneWidget,
    );
    expect(
      find.text(VisaStrings.t('visa_section_guides', 'English')),
      findsOneWidget,
    );
  });
}
