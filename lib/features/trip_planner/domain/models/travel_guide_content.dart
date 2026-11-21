/// Static travel guide sections — offline-first, expandable per country.
class TravelGuideSection {
  const TravelGuideSection({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    this.tipsKeys = const [],
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final List<String> tipsKeys;
}

abstract final class TravelGuideContent {
  static const culture = [
    TravelGuideSection(
      id: 'greetings',
      titleKey: 'guide_greetings_title',
      bodyKey: 'guide_greetings_body',
      tipsKeys: ['guide_greetings_tip1', 'guide_greetings_tip2'],
    ),
    TravelGuideSection(
      id: 'dress',
      titleKey: 'guide_dress_title',
      bodyKey: 'guide_dress_body',
      tipsKeys: ['guide_dress_tip1', 'guide_dress_tip2'],
    ),
    TravelGuideSection(
      id: 'hospitality',
      titleKey: 'guide_hospitality_title',
      bodyKey: 'guide_hospitality_body',
    ),
    TravelGuideSection(
      id: 'food',
      titleKey: 'guide_food_title',
      bodyKey: 'guide_food_body',
    ),
    TravelGuideSection(
      id: 'photography',
      titleKey: 'guide_photo_title',
      bodyKey: 'guide_photo_body',
    ),
  ];

  static const dosDonts = [
    TravelGuideSection(
      id: 'do_respect',
      titleKey: 'dos_respect_title',
      bodyKey: 'dos_respect_body',
    ),
    TravelGuideSection(
      id: 'dont_public',
      titleKey: 'dont_public_title',
      bodyKey: 'dont_public_body',
    ),
    TravelGuideSection(
      id: 'dont_photo',
      titleKey: 'dont_photo_title',
      bodyKey: 'dont_photo_body',
    ),
    TravelGuideSection(
      id: 'dont_alcohol',
      titleKey: 'dont_alcohol_title',
      bodyKey: 'dont_alcohol_body',
    ),
    TravelGuideSection(
      id: 'dont_mosque',
      titleKey: 'dont_mosque_title',
      bodyKey: 'dont_mosque_body',
    ),
  ];

  static const ramadanTourist = [
    TravelGuideSection(
      id: 'ramadan_what',
      titleKey: 'ramadan_what_title',
      bodyKey: 'ramadan_what_body',
    ),
    TravelGuideSection(
      id: 'ramadan_eating',
      titleKey: 'ramadan_eating_title',
      bodyKey: 'ramadan_eating_body',
    ),
    TravelGuideSection(
      id: 'ramadan_hours',
      titleKey: 'ramadan_hours_title',
      bodyKey: 'ramadan_hours_body',
    ),
    TravelGuideSection(
      id: 'ramadan_iftar',
      titleKey: 'ramadan_iftar_title',
      bodyKey: 'ramadan_iftar_body',
    ),
    TravelGuideSection(
      id: 'ramadan_avoid',
      titleKey: 'ramadan_avoid_title',
      bodyKey: 'ramadan_avoid_body',
    ),
  ];

  static const transport = [
    TravelGuideSection(
      id: 'metro',
      titleKey: 'transport_metro_title',
      bodyKey: 'transport_metro_body',
      tipsKeys: ['transport_metro_tip1', 'transport_metro_tip2'],
    ),
    TravelGuideSection(
      id: 'taxi',
      titleKey: 'transport_taxi_title',
      bodyKey: 'transport_taxi_body',
    ),
    TravelGuideSection(
      id: 'airport',
      titleKey: 'transport_airport_title',
      bodyKey: 'transport_airport_body',
    ),
    TravelGuideSection(
      id: 'costs',
      titleKey: 'transport_costs_title',
      bodyKey: 'transport_costs_body',
    ),
  ];
}
