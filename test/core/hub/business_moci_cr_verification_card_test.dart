import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/businesses/data/moci_cr_verification_catalog.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:raabta/screens/businesses/widgets/business_moci_cr_verification_card.dart';

void main() {
  group('BusinessMociCrVerificationCard', () {
    test('CR copy states no checksum and live registry requirement', () {
      const locale = 'English';
      final summary =
          BusinessesStrings.t('biz_trust_cr_verify_summary', locale);
      expect(summary.toLowerCase(), contains('no checksum'));
      expect(summary.toLowerCase(), contains('live registry'));
      expect(summary.toLowerCase(), isNot(contains('looks right')));
    });

    test('CR fine wording ties QAR 200,000 to specific exploitation violations', () {
      const locale = 'English';
      final summary =
          BusinessesStrings.t('biz_trust_cr_verify_summary', locale);
      expect(summary.toLowerCase(), contains('200,000'));
      expect(summary.toLowerCase(), contains('exploit'));
      expect(summary.toLowerCase(), contains('these violations'));
      expect(summary.toLowerCase(), isNot(contains('lending')));
      expect(summary.toLowerCase(), isNot(contains('lend')));
    });

    test('QFC copy scopes to QFC/QFCRA businesses only', () {
      const locale = 'English';
      final title = BusinessesStrings.t('biz_trust_qfc_title', locale);
      final summary = BusinessesStrings.t('biz_trust_qfc_summary', locale);
      expect(title.toLowerCase(), contains('qfc'));
      expect(summary.toLowerCase(), contains('qatar financial centre'));
      expect(summary.toLowerCase(), contains('qfc/qfcra'));
      expect(
        summary.toLowerCase(),
        contains('does not by itself establish that the business is illegitimate'),
      );
      expect(summary.toLowerCase(), isNot(contains('universal')));
      expect(summary.toLowerCase(), isNot(contains('all qatar businesses')));
    });

    test('disclaimer does not claim Raabta verified registration', () {
      const locale = 'English';
      final disclaimer =
          BusinessesStrings.t('biz_trust_cr_disclaimer', locale);
      expect(disclaimer.toLowerCase(), contains('has not checked'));
      expect(disclaimer.toLowerCase(), isNot(contains('verified this listing')));
    });

    test('registry URLs are official durable endpoints', () {
      expect(
        MociCrVerificationCatalog.mociBusinessMapUrl,
        'https://businessmap.moci.gov.qa/',
      );
      expect(
        MociCrVerificationCatalog.qatarCidUrl,
        startsWith('https://www.qatarcid.com'),
      );
      expect(
        MociCrVerificationCatalog.qfcPublicRegisterUrl,
        contains('qfcra.com/public_registers'),
      );
    });

    test('Arabic strings resolve for trust card keys', () {
      const keys = [
        'biz_trust_cr_card_title',
        'biz_trust_cr_verify_title',
        'biz_trust_qfc_title',
      ];
      for (final key in keys) {
        final ar = BusinessesStrings.t(key, 'Arabic');
        final en = BusinessesStrings.t(key, 'English');
        expect(ar, isNot(equals(key)));
        expect(ar, isNotEmpty);
        expect(ar, isNot(equals(en)));
      }
    });

    test('Arabic CR and QFC summaries use corrected factual wording', () {
      final crAr =
          BusinessesStrings.t('biz_trust_cr_verify_summary', 'Arabic');
      final qfcAr = BusinessesStrings.t('biz_trust_qfc_summary', 'Arabic');
      expect(crAr, contains('200,000'));
      expect(crAr, isNot(contains('إعارة')));
      expect(qfcAr, contains('QFC'));
      expect(qfcAr, contains('QFCRA'));
    });

    testWidgets('renders MOCI, Qatar Chamber, and QFC link buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BusinessMociCrVerificationCard(locale: 'English'),
            ),
          ),
        ),
      );

      expect(
        find.text(BusinessesStrings.t('biz_trust_cr_moci_button', 'English')),
        findsOneWidget,
      );
      expect(
        find.text(
          BusinessesStrings.t('biz_trust_cr_qatarcid_button', 'English'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(BusinessesStrings.t('biz_trust_qfc_button', 'English')),
        findsOneWidget,
      );
      expect(find.byType(OutlinedButton), findsNWidgets(3));
    });

    test('due diligence items cover license and chamber checks', () {
      const locale = 'English';
      final item1 =
          BusinessesStrings.t('biz_trust_diligence_item_1', locale);
      final item2 =
          BusinessesStrings.t('biz_trust_diligence_item_2', locale);
      final item3 =
          BusinessesStrings.t('biz_trust_diligence_item_3', locale);
      expect(item1.toLowerCase(), contains('license'));
      expect(item2.toLowerCase(), contains('chamber'));
      expect(item3.toLowerCase(), contains('reluctance'));
    });
  });
}
