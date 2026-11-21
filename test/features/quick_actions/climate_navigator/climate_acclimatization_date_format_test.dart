import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_date_format.dart';

void main() {
  test('Filipino date formatting uses fallback without throwing', () {
    final text = ClimateAcclimatizationDateFormat.format(
      DateTime(2026, 7, 4),
      'Filipino',
    );
    expect(text, isNotEmpty);
    expect(text, contains('2026'));
  });

  test('English date formatting', () {
    final text = ClimateAcclimatizationDateFormat.format(
      DateTime(2026, 7, 4),
      'English',
    );
    expect(text, contains('2026'));
  });
}
