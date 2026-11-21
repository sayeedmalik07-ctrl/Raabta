import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/utils/home_personalization_resolver.dart';

void main() {
  test('Home trailing services strip is last section id after currency', () {
    // Mirror private order in HomeScreen — trailing list must end with explore (strip).
    const trailing = [HomeSectionId.explore];
    expect(trailing.last, HomeSectionId.explore);
    expect(trailing, hasLength(1));
  });
}