import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/widgets/service_sponsorship_awareness_section.dart';

void main() {
  group('ServiceSponsorshipAwarenessSection', () {
    test('copy references Article 15 without accusing a specific provider', () {
      const locale = 'English';
      final teaser =
          ServicesStrings.t('svc_sponsorship_awareness_teaser', locale);
      final disclaimer =
          ServicesStrings.t('svc_sponsorship_awareness_disclaimer', locale);
      final art15 =
          ServicesStrings.t('svc_sponsorship_awareness_art15', locale);
      expect(teaser.toLowerCase(), contains('not about this listing'));
      expect(disclaimer.toLowerCase(), contains('not a judgment'));
      expect(art15.toLowerCase(), contains('article 15'));
      expect(art15.toLowerCase(), contains('50,000'));
    });

    test('copy notes licensed business as lower-risk alternative', () {
      const locale = 'English';
      final licensed =
          ServicesStrings.t('svc_sponsorship_awareness_licensed', locale);
      expect(licensed.toLowerCase(), contains('licensed company'));
    });

    test('disclaimer states Raabta has not verified sponsorship', () {
      const locale = 'English';
      final disclaimer =
          ServicesStrings.t('svc_sponsorship_awareness_disclaimer', locale);
      expect(disclaimer.toLowerCase(), contains('has not verified'));
    });

    test('Arabic title resolves distinctly from English', () {
      final ar =
          ServicesStrings.t('svc_sponsorship_awareness_title', 'Arabic');
      final en =
          ServicesStrings.t('svc_sponsorship_awareness_title', 'English');
      expect(ar, isNot(equals(en)));
      expect(ar, isNotEmpty);
    });

    testWidgets('renders collapsed expansion tile by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceSponsorshipAwarenessSection(locale: 'English'),
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(
        find.text(ServicesStrings.t('svc_sponsorship_awareness_title', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(
          ServicesStrings.t('svc_sponsorship_awareness_art15', 'English'),
        ),
        findsNothing,
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Article 15'),
        findsOneWidget,
      );
      expect(
        find.text(
          ServicesStrings.t('svc_sponsorship_awareness_freelance_link', 'English'),
        ),
        findsOneWidget,
      );
    });
  });
}
