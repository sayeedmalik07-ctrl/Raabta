import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/l10n/home_truth_chip_ui_strings.dart';
import 'package:raabta/features/home/l10n/home_truth_engine_section_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_eosb_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_health_insurance_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_sponsorship_transfer_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_tenancy_strings.dart';

void main() {
  final catalogs = <String, Map<String, Set<String>>>{
    'HomeTruthEngineSectionStrings':
        HomeTruthEngineSectionStrings.localeCoverageReport,
    'HomeTruthChipUiStrings': HomeTruthChipUiStrings.localeCoverageReport,
    'TruthChipEosbStrings': TruthChipEosbStrings.localeCoverageReport,
    'TruthChipSponsorshipTransferStrings':
        TruthChipSponsorshipTransferStrings.localeCoverageReport,
    'TruthChipTenancyStrings': TruthChipTenancyStrings.localeCoverageReport,
    'TruthChipHealthInsuranceStrings':
        TruthChipHealthInsuranceStrings.localeCoverageReport,
  };

  group('Truth chip l10n — nine-locale catalog coverage', () {
    for (final entry in catalogs.entries) {
      test('${entry.key} has no missing locales', () {
        expect(entry.value, isEmpty);
      });
    }
  });

  group('Truth chip l10n — no English copy on Arabic/Urdu', () {
    test('mapper invite strings differ from English', () {
      for (final locale in ['Arabic', 'Urdu']) {
        expect(
          TruthChipEosbStrings.t('truth_chip_eosb_invite', locale),
          isNot(TruthChipEosbStrings.t('truth_chip_eosb_invite', 'English')),
        );
        expect(
          TruthChipTenancyStrings.t('truth_chip_tenancy_invite', locale),
          isNot(
            TruthChipTenancyStrings.t('truth_chip_tenancy_invite', 'English'),
          ),
        );
      }
    });

    test('section eye strings differ from English for Arabic', () {
      expect(
        HomeTruthEngineSectionStrings.t('home_truth_eye_show', 'Arabic'),
        isNot(
          HomeTruthEngineSectionStrings.t('home_truth_eye_show', 'English'),
        ),
      );
    });
  });
}
