import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_salary_claude_consent_feedback.dart';

void main() {
  testWidgets('consent SnackBar shows localized message and privacy action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) {
                return Scaffold(
                  body: Builder(
                    builder: (context) {
                      return TextButton(
                        onPressed: () => showEosbSalaryClaudeConsentSnackBar(
                          context,
                          'English',
                        ),
                        child: const Text('trigger'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('trigger'));
    await tester.pump();

    final message = EosbStrings.t(
      'eosb_salary_claude_consent_required',
      'English',
    );
    expect(find.text(message), findsOneWidget);
    expect(
      find.text(EosbStrings.t('eosb_privacy_security', 'English')),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(SnackBarAction), findsOneWidget);
  });
}
