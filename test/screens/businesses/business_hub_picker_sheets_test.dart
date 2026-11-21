import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:raabta/screens/businesses/widgets/business_hub_picker_sheets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Business hub picker sheets', () {
    testWidgets('category picker uses hub sheet chrome', (tester) async {
      const locale = 'English';
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      showBusinessCategoryPicker(
                        context: context,
                        locale: locale,
                        selectedIndex: 0,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(HubPickerSheet.sheetKey), findsOneWidget);
      expect(
        find.text(BusinessesStrings.t('hub_picker_category_title', locale)),
        findsOneWidget,
      );
      expect(find.text('Restaurants'), findsOneWidget);
    });

    testWidgets('filters sheet exposes hub filter rows', (tester) async {
      const locale = 'English';
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      showBusinessFiltersSheet(
                        context: context,
                        locale: locale,
                        selectedCategoryIndex: 0,
                        openNowOnly: false,
                        areaFilter: null,
                        onClearAll: () {},
                        onCategoryChanged: (_) {},
                        onOpenNowChanged: (_) {},
                        onAreaChanged: (_) {},
                      );
                    },
                    child: const Text('Filters'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();

      expect(find.byKey(HubPickerSheet.sheetKey), findsOneWidget);
      expect(
        find.text(BusinessesStrings.t('hub_filter_sheet_subtitle', locale)),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('business_hub_filter_sheet_category')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('business_hub_filter_sheet_open_now')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('business_hub_filter_sheet_area')),
        findsOneWidget,
      );
    });
  });
}
