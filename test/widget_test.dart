import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:raabta/main.dart';

void main() {
  testWidgets('Raabta splash screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const RaabtaApp());

    expect(find.text('Raabta'), findsOneWidget);
    expect(find.text('Your Qatar Connection'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
