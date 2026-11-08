import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/utils/home_header_context_line.dart';
import 'package:raabta/features/home/widgets/glass_status_header.dart';

void main() {
  group('HomeHeaderContextLine', () {
    test('rejects dash-only preferred area', () {
      final parts = HomeHeaderContextLine.composeParts(
        locale: 'English',
        preferredArea: '—',
        weather: null,
      );
      expect(parts?.area, isNull);
      expect(parts?.visibleSegments(locale: 'English'), ['Qatar']);
    });

    test('joins country temp and area when present', () {
      final parts = HomeHeaderContextLine.composeParts(
        locale: 'English',
        preferredArea: 'West Bay',
        weather: null,
      );
      expect(
        parts?.visibleSegments(locale: 'English'),
        ['Qatar', 'West Bay'],
      );
    });

  });

  test('notification badge labels cap at 9+', () {
    expect(headerNotificationBadgeLabelForTest(0), '');
    expect(headerNotificationBadgeLabelForTest(3), '3');
    expect(headerNotificationBadgeLabelForTest(12), '9+');
  });
}
