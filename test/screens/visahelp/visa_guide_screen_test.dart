import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';
import 'package:raabta/screens/visahelp/visa_guide_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visa guide uses hub shell and shows fallback guide', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          visaGuideProvider('iqama_renewal').overrideWith(
            (ref) => Future.value(fallbackVisaGuide('iqama_renewal', 'English')),
          ),
        ],
        child: const MaterialApp(
          home: VisaGuideScreen(categoryId: 'iqama_renewal'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HubSubscreenScaffold), findsOneWidget);
    expect(find.text(fallbackVisaGuide('iqama_renewal', 'English').title), findsOneWidget);
    final stepsLabel = VisaStrings.format(
      'visa_steps_count',
      'English',
      params: {'count': '5'},
    );
    expect(
      find.text(VisaStrings.format(
        'visa_guide_meta',
        'English',
        params: {'steps': stepsLabel, 'eta': '3–5 days'},
      )),
      findsOneWidget,
    );
  });
}
