/// Presentation layer: 12 hub front groups (Decision D2/D3).
/// Maps onto the 24 canonical [ServiceCategory.id] values — leaf IDs unchanged.
library;

import 'package:flutter/material.dart';

/// Stable ids for the 12 Services landing front groups (never rename: persisted UX keys).
abstract final class ServiceFrontGroupIds {
  static const cleaningLaundry = 'fg_cleaning_laundry';
  static const repairInstallation = 'fg_repair_installation';
  static const pestOutdoor = 'fg_pest_outdoor';
  static const movingTransport = 'fg_moving_transport';
  static const carCare = 'fg_car_care';
  static const beautyWellness = 'fg_beauty_wellness';
  static const childcareEducation = 'fg_childcare_education';
  static const healthCare = 'fg_health_care';
  static const eventsPetsLifestyle = 'fg_events_pets_lifestyle';
  static const businessProfessional = 'fg_business_professional';
  static const digitalFreelance = 'fg_digital_freelance';
  static const securityEmergency = 'fg_security_emergency';

  /// All ids in hub tile order (1..12).
  static const List<String> orderedIds = [
    cleaningLaundry,
    repairInstallation,
    pestOutdoor,
    movingTransport,
    carCare,
    beautyWellness,
    childcareEducation,
    healthCare,
    eventsPetsLifestyle,
    businessProfessional,
    digitalFreelance,
    securityEmergency,
  ];
}

/// English display names only; reviewed translations land in [ServicesStrings] in a later batch.
abstract final class ServiceFrontGroupLabels {
  static const Map<String, String> english = {
    ServiceFrontGroupIds.cleaningLaundry: 'Cleaning and laundry',
    ServiceFrontGroupIds.repairInstallation: 'Repair and installation',
    ServiceFrontGroupIds.pestOutdoor: 'Pest and outdoor',
    ServiceFrontGroupIds.movingTransport: 'Moving and transport',
    ServiceFrontGroupIds.carCare: 'Car care',
    ServiceFrontGroupIds.beautyWellness: 'Beauty and wellness',
    ServiceFrontGroupIds.childcareEducation: 'Childcare and education',
    ServiceFrontGroupIds.healthCare: 'Health and care',
    ServiceFrontGroupIds.eventsPetsLifestyle: 'Events, pets and lifestyle',
    ServiceFrontGroupIds.businessProfessional: 'Business and professional',
    ServiceFrontGroupIds.digitalFreelance: 'Digital and freelance',
    ServiceFrontGroupIds.securityEmergency: 'Security and emergency',
  };

  /// First category [ServiceCategory.id] in each front group — T2 entry for the tile.
  static const Map<String, String> anchorCategoryIdByFrontGroup = {
    ServiceFrontGroupIds.cleaningLaundry: 'home_cleaning',
    ServiceFrontGroupIds.repairInstallation: 'home_maintenance',
    ServiceFrontGroupIds.pestOutdoor: 'pest_control',
    ServiceFrontGroupIds.movingTransport: 'moving_services',
    ServiceFrontGroupIds.carCare: 'automotive',
    ServiceFrontGroupIds.beautyWellness: 'beauty_wellness',
    ServiceFrontGroupIds.childcareEducation: 'childcare',
    ServiceFrontGroupIds.healthCare: 'home_healthcare',
    ServiceFrontGroupIds.eventsPetsLifestyle: 'event_services',
    ServiceFrontGroupIds.businessProfessional: 'business_services',
    ServiceFrontGroupIds.digitalFreelance: 'digital_services',
    ServiceFrontGroupIds.securityEmergency: 'security_services',
  };

  static const Map<String, IconData> iconByFrontGroup = {
    ServiceFrontGroupIds.cleaningLaundry: Icons.cleaning_services_rounded,
    ServiceFrontGroupIds.repairInstallation: Icons.handyman_rounded,
    ServiceFrontGroupIds.pestOutdoor: Icons.pest_control_rounded,
    ServiceFrontGroupIds.movingTransport: Icons.local_shipping_rounded,
    ServiceFrontGroupIds.carCare: Icons.directions_car_rounded,
    ServiceFrontGroupIds.beautyWellness: Icons.spa_rounded,
    ServiceFrontGroupIds.childcareEducation: Icons.family_restroom_rounded,
    ServiceFrontGroupIds.healthCare: Icons.medical_services_rounded,
    ServiceFrontGroupIds.eventsPetsLifestyle: Icons.celebration_rounded,
    ServiceFrontGroupIds.businessProfessional: Icons.business_center_rounded,
    ServiceFrontGroupIds.digitalFreelance: Icons.computer_rounded,
    ServiceFrontGroupIds.securityEmergency: Icons.security_rounded,
  };

  static String? labelEnglish(String frontGroupId) => english[frontGroupId];

  static String? anchorCategoryId(String frontGroupId) =>
      anchorCategoryIdByFrontGroup[frontGroupId];

  static IconData iconFor(String frontGroupId) =>
      iconByFrontGroup[frontGroupId] ?? Icons.category_rounded;
}
