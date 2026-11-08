import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_deadline_urgency_row.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/deadline_tracker.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DeadlineTrackerWidget loading shows hub skeleton', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          documentDeadlinesProvider.overrideWith(
            (ref) => Stream<List<DocumentDeadline>>.empty(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DeadlineTrackerWidget()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
  });

  testWidgets('DeadlineTrackerWidget shows urgency row when data loaded',
      (tester) async {
    final expiry = DateTime.now().add(const Duration(days: 10));
    final deadline = DocumentDeadline(
      id: 'd1',
      documentType: 'Qatar ID (QID)',
      expiryDate: expiry,
      guideCategoryId: 'qatar_id',
      typeId: 'qatarId',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          documentDeadlinesProvider.overrideWith(
            (ref) => Stream.value([deadline]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DeadlineTrackerWidget()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HubDeadlineUrgencyRow), findsWidgets);
    expect(
      find.text(
        VisaStrings.t('visa_deadline_tracker_title', 'English'),
      ),
      findsOneWidget,
    );
  });
}
