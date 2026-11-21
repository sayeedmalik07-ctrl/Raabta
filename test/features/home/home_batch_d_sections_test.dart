import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/utils/home_personalization_resolver.dart';

void main() {
  test('default Home section order places exchange rates before for you', () {
    const order = [
      HomeSectionId.trust,
      HomeSectionId.qatarLife,
      HomeSectionId.dailyEssentials,
      HomeSectionId.exchangeRates,
      HomeSectionId.forYou,
      HomeSectionId.explore,
    ];
    final exchangeIndex = order.indexOf(HomeSectionId.exchangeRates);
    final forYouIndex = order.indexOf(HomeSectionId.forYou);
    expect(forYouIndex - exchangeIndex, 1);
  });

  test('resolver default includes exchange rates before for you', () {
    final resolved = HomePersonalizationResolver.sectionOrder(
      const HomePersonalizationInput(),
    );
    expect(
      resolved.indexOf(HomeSectionId.exchangeRates),
      resolved.indexOf(HomeSectionId.forYou) - 1,
    );
  });
}