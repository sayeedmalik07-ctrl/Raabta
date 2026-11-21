import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/home_all_services_catalog.dart';
import 'package:raabta/features/home/screens/home_all_services_screen.dart';
import 'package:raabta/providers/visa_providers.dart';

void main() {
  test('catalog entries expose subtitle keys', () {
    for (final entry in kHomeAllServiceEntries) {
      expect(entry.subtitleKey, isNotEmpty);
    }
  });

  testWidgets('All services uses grouped hub list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
        ],
        child: const MaterialApp(
          home: HomeAllServicesScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('home_all_services_grouped_list')),
      findsOneWidget,
    );
    expect(find.text('Housing'), findsOneWidget);
    expect(find.text('Find your home'), findsOneWidget);
    expect(find.text('Compare rates'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(kHomeAllServiceEntries.length - 1));
  });
}