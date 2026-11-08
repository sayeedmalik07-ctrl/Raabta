import 'package:flutter/material.dart';
import 'package:raabta/screens/services/data/service_front_groups.dart';
import 'package:raabta/screens/services/models/service_category.dart';

/// Full service taxonomy — static local data, zero Firestore reads.
///
/// Presentation fields follow [docs/raabta_services_modernization_decision.md] §5–6.
const List<ServiceCategory> kServiceCategories = [
  // —— Front group 1: Cleaning and laundry ——
  ServiceCategory(
    id: 'home_cleaning',
    name: 'Home Cleaning',
    icon: Icons.cleaning_services_rounded,
    frontGroupId: ServiceFrontGroupIds.cleaningLaundry,
    presentationOrder: 1,
    isPopular: true,
    searchAliases: ['cleaning', 'maid', 'housekeeping', 'deep clean'],
    subServices: [
      'Regular cleaning',
      'Deep cleaning',
      'Move in and move out cleaning',
      'Villa cleaning',
      'Apartment cleaning',
      'Office cleaning',
      'Sofa cleaning',
      'Carpet cleaning',
      'Mattress cleaning',
      'Curtain cleaning',
      'Kitchen cleaning',
      'Bathroom sanitization',
      'Water tank cleaning',
      'Pressure washing',
      'Window cleaning',
    ],
  ),
  ServiceCategory(
    id: 'laundry',
    name: 'Laundry',
    icon: Icons.local_laundry_service_rounded,
    frontGroupId: ServiceFrontGroupIds.cleaningLaundry,
    presentationOrder: 2,
    isPopular: false,
    searchAliases: ['wash and fold', 'dry clean', 'ironing'],
    subServices: [
      'Laundry pickup',
      'Dry cleaning',
      'Ironing',
      'Shoe cleaning',
      'Bag cleaning',
    ],
  ),
  // —— Front group 2: Repair and installation ——
  ServiceCategory(
    id: 'home_maintenance',
    name: 'Home Maintenance',
    icon: Icons.handyman_rounded,
    frontGroupId: ServiceFrontGroupIds.repairInstallation,
    presentationOrder: 3,
    isPopular: true,
    searchAliases: ['handyman', 'plumber', 'electrician', 'AC'],
    subServices: [
      'AC repair',
      'AC installation',
      'AC servicing',
      'Plumbing',
      'Electrical repair',
      'Handyman',
      'Painting',
      'Carpentry',
      'Furniture assembly',
      'Door repair',
      'Lock repair',
      'Ceiling repair',
      'Tile repair',
      'Gypsum work',
      'Waterproofing',
    ],
  ),
  ServiceCategory(
    id: 'appliance_repair',
    name: 'Appliance Repair',
    icon: Icons.kitchen_rounded,
    frontGroupId: ServiceFrontGroupIds.repairInstallation,
    presentationOrder: 4,
    isPopular: false,
    searchAliases: ['fridge', 'washing machine repair'],
    subServices: [
      'Refrigerator',
      'Washing machine',
      'Dishwasher',
      'Microwave',
      'Oven',
      'Water dispenser',
      'Water heater',
    ],
  ),
  ServiceCategory(
    id: 'electronics_repair',
    name: 'Electronics Repair',
    icon: Icons.phone_android_rounded,
    frontGroupId: ServiceFrontGroupIds.repairInstallation,
    presentationOrder: 5,
    isPopular: false,
    searchAliases: ['phone repair', 'laptop', 'computer', 'TV'],
    subServices: [
      'Mobile repair',
      'Laptop repair',
      'Computer repair',
      'Printer repair',
      'TV repair',
      'CCTV installation',
      'WiFi installation',
      'Smart home installation',
    ],
  ),
  ServiceCategory(
    id: 'home_installation',
    name: 'Home Installation',
    icon: Icons.home_repair_service_rounded,
    frontGroupId: ServiceFrontGroupIds.repairInstallation,
    presentationOrder: 6,
    isPopular: false,
    searchAliases: ['mount TV', 'curtains', 'blinds'],
    subServices: [
      'Curtains',
      'Blinds',
      'Wallpaper',
      'TV mounting',
      'Shelving',
      'Smart locks',
      'Water filters',
    ],
  ),
  // —— Front group 3: Pest and outdoor ——
  ServiceCategory(
    id: 'pest_control',
    name: 'Pest Control',
    icon: Icons.pest_control_rounded,
    frontGroupId: ServiceFrontGroupIds.pestOutdoor,
    presentationOrder: 7,
    isPopular: false,
    searchAliases: ['bugs', 'cockroach', 'termites'],
    subServices: [
      'Cockroach treatment',
      'Bed bug treatment',
      'Termite control',
      'Rodent control',
      'Mosquito control',
      'Ant control',
      'Bird control',
      'Disinfection service',
    ],
  ),
  ServiceCategory(
    id: 'outdoor_services',
    name: 'Outdoor Services',
    icon: Icons.yard_rounded,
    frontGroupId: ServiceFrontGroupIds.pestOutdoor,
    presentationOrder: 8,
    isPopular: false,
    searchAliases: ['garden', 'pool', 'landscape'],
    subServices: [
      'Gardening',
      'Landscaping',
      'Lawn maintenance',
      'Tree trimming',
      'Irrigation',
      'Pool cleaning',
      'Pool maintenance',
    ],
  ),
  // —— Front group 4: Moving and transport ——
  ServiceCategory(
    id: 'moving_services',
    name: 'Moving Services',
    icon: Icons.local_shipping_rounded,
    frontGroupId: ServiceFrontGroupIds.movingTransport,
    presentationOrder: 9,
    isPopular: false,
    searchAliases: ['movers', 'relocation', 'packing'],
    subServices: [
      'Home shifting',
      'Office relocation',
      'Furniture moving',
      'Packing service',
      'Unpacking',
      'Storage service',
      'Disposal service',
    ],
  ),
  // —— Front group 5: Car care ——
  ServiceCategory(
    id: 'automotive',
    name: 'Automotive',
    icon: Icons.directions_car_rounded,
    frontGroupId: ServiceFrontGroupIds.carCare,
    presentationOrder: 10,
    isPopular: true,
    searchAliases: ['car', 'vehicle', 'detailing'],
    subServices: [
      'Car wash',
      'Mobile car wash',
      'Car detailing',
      'Oil change',
      'Battery replacement',
      'Tyre replacement',
      'Car recovery',
      'Vehicle inspection',
    ],
  ),
  // —— Front group 6: Beauty and wellness ——
  ServiceCategory(
    id: 'beauty_wellness',
    name: 'Beauty and Wellness',
    icon: Icons.spa_rounded,
    frontGroupId: ServiceFrontGroupIds.beautyWellness,
    presentationOrder: 11,
    isPopular: false,
    searchAliases: ['salon', 'massage', 'hair', 'spa'],
    subServices: [
      'Home salon',
      'Haircut',
      'Hair coloring',
      'Makeup artist',
      'Bridal makeup',
      'Nail services',
      'Facial',
      'Massage',
      'Spa at home',
      'Personal trainer',
      'Yoga instructor',
    ],
  ),
  // —— Front group 7: Childcare and education ——
  ServiceCategory(
    id: 'childcare',
    name: 'Childcare',
    icon: Icons.child_care_rounded,
    frontGroupId: ServiceFrontGroupIds.childcareEducation,
    presentationOrder: 12,
    isPopular: false,
    searchAliases: ['babysitter', 'nanny'],
    subServices: [
      'Babysitter',
      'Nanny',
      'After school care',
      'Infant care',
      'Weekend nanny',
    ],
  ),
  ServiceCategory(
    id: 'education',
    name: 'Education',
    icon: Icons.school_rounded,
    frontGroupId: ServiceFrontGroupIds.childcareEducation,
    presentationOrder: 13,
    isPopular: false,
    searchAliases: ['tutor', 'tuition', 'IELTS'],
    subServices: [
      'Home tuition',
      'Online tuition',
      'Quran teacher',
      'Arabic teacher',
      'English teacher',
      'IELTS coaching',
      'School subject coaching',
      'Coding classes',
      'Music lessons',
      'Art classes',
      'Chess coaching',
      'Robotics classes',
    ],
  ),
  // —— Front group 8: Health and care ——
  ServiceCategory(
    id: 'home_healthcare',
    name: 'Home Healthcare',
    icon: Icons.medical_services_rounded,
    frontGroupId: ServiceFrontGroupIds.healthCare,
    presentationOrder: 14,
    isPopular: false,
    searchAliases: ['nurse', 'caregiver', 'physio'],
    subServices: [
      'Home nurse',
      'Elderly care',
      'Caregiver',
      'Physiotherapy at home',
      'Doctor home visit',
      'Baby care nurse',
      'Post surgery care',
      'Blood sample collection',
      'Medical equipment rental',
    ],
  ),
  // —— Front group 9: Events, pets and lifestyle ——
  ServiceCategory(
    id: 'event_services',
    name: 'Event Services',
    icon: Icons.celebration_rounded,
    frontGroupId: ServiceFrontGroupIds.eventsPetsLifestyle,
    presentationOrder: 15,
    isPopular: false,
    searchAliases: ['wedding', 'photographer', 'catering', 'DJ'],
    subServices: [
      'Photography',
      'Videography',
      'Catering',
      'Birthday decoration',
      'Wedding decoration',
      'Sound system rental',
      'DJ',
      'Event planner',
    ],
  ),
  ServiceCategory(
    id: 'pet_services',
    name: 'Pet Services',
    icon: Icons.pets_rounded,
    frontGroupId: ServiceFrontGroupIds.eventsPetsLifestyle,
    presentationOrder: 16,
    isPopular: false,
    searchAliases: ['dog', 'cat', 'vet'],
    subServices: [
      'Pet grooming',
      'Pet boarding',
      'Pet sitting',
      'Dog walking',
      'Pet training',
      'Veterinary home visit',
    ],
  ),
  ServiceCategory(
    id: 'travel_lifestyle',
    name: 'Travel and Lifestyle',
    icon: Icons.flight_rounded,
    frontGroupId: ServiceFrontGroupIds.eventsPetsLifestyle,
    presentationOrder: 17,
    isPopular: false,
    searchAliases: ['driver', 'chauffeur', 'airport'],
    subServices: [
      'Airport pickup',
      'Chauffeur',
      'Private driver',
      'Tour guide',
      'Translator',
      'Personal shopper',
    ],
  ),
  ServiceCategory(
    id: 'religious_services',
    name: 'Religious Services',
    icon: Icons.menu_book_rounded,
    frontGroupId: ServiceFrontGroupIds.eventsPetsLifestyle,
    presentationOrder: 18,
    isPopular: false,
    searchAliases: ['quran', 'islamic'],
    subServices: [
      'Quran tutor',
      'Islamic studies teacher',
      'Hajj and Umrah assistance',
    ],
  ),
  // —— Front group 10: Business and professional ——
  ServiceCategory(
    id: 'business_services',
    name: 'Business Services',
    icon: Icons.business_center_rounded,
    frontGroupId: ServiceFrontGroupIds.businessProfessional,
    presentationOrder: 19,
    isPopular: false,
    searchAliases: ['office', 'PRO', 'printing'],
    subServices: [
      'Office cleaning',
      'Office maintenance',
      'Office boy',
      'Receptionist',
      'Document delivery',
      'Printing',
      'Translation',
      'PRO services',
    ],
  ),
  ServiceCategory(
    id: 'professional_services',
    name: 'Professional Services',
    icon: Icons.work_rounded,
    frontGroupId: ServiceFrontGroupIds.businessProfessional,
    presentationOrder: 20,
    isPopular: false,
    searchAliases: ['lawyer', 'accountant', 'legal'],
    subServices: [
      'Lawyer',
      'Accountant',
      'Tax consultant',
      'Insurance advisor',
      'Financial consultant',
      'Business setup consultant',
    ],
  ),
  // —— Front group 11: Digital and freelance ——
  ServiceCategory(
    id: 'digital_services',
    name: 'Digital Services',
    icon: Icons.computer_rounded,
    frontGroupId: ServiceFrontGroupIds.digitalFreelance,
    presentationOrder: 21,
    isPopular: false,
    searchAliases: ['website', 'design', 'SEO', 'developer'],
    subServices: [
      'Graphic design',
      'Website development',
      'App development',
      'Digital marketing',
      'SEO',
      'Video editing',
      'Content writing',
    ],
  ),
  ServiceCategory(
    id: 'freelancers',
    name: 'Freelancers',
    icon: Icons.person_search_rounded,
    frontGroupId: ServiceFrontGroupIds.digitalFreelance,
    presentationOrder: 22,
    isPopular: false,
    searchAliases: ['contractor', 'gig'],
    subServices: [
      'Photographer',
      'Translator',
      'Designer',
      'Developer',
      'Accountant',
      'Consultant',
      'Voice over artist',
    ],
  ),
  // —— Front group 12: Security and emergency ——
  ServiceCategory(
    id: 'security_services',
    name: 'Security Services',
    icon: Icons.security_rounded,
    frontGroupId: ServiceFrontGroupIds.securityEmergency,
    presentationOrder: 23,
    isPopular: false,
    searchAliases: ['CCTV', 'guard', 'alarm'],
    subServices: [
      'Security guard',
      'CCTV monitoring',
      'Alarm installation',
      'Access control',
    ],
  ),
  ServiceCategory(
    id: 'emergency_services',
    name: 'Emergency Services',
    icon: Icons.emergency_rounded,
    frontGroupId: ServiceFrontGroupIds.securityEmergency,
    presentationOrder: 24,
    isPopular: false,
    searchAliases: ['urgent', '24 hour'],
    subServices: [
      'Emergency plumber',
      'Emergency electrician',
      'Emergency locksmith',
      'Emergency AC repair',
      'Emergency towing',
    ],
  ),
];

ServiceCategory? findServiceCategoryById(String id) {
  for (final category in kServiceCategories) {
    if (category.id == id) return category;
  }
  return null;
}

/// Categories that map to a front-group tile (Decision §5), stable order.
List<ServiceCategory> categoriesForFrontGroup(String frontGroupId) {
  final list =
      kServiceCategories.where((c) => c.frontGroupId == frontGroupId).toList();
  list.sort((a, b) => a.presentationOrder.compareTo(b.presentationOrder));
  return list;
}

/// Whether [query] matches this front group (label, member categories, aliases, leaves).
bool frontGroupMatchesQuery(String frontGroupId, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;

  final fgLabel =
      ServiceFrontGroupLabels.labelEnglish(frontGroupId)?.toLowerCase();
  if (fgLabel != null && fgLabel.contains(q)) return true;

  for (final c in categoriesForFrontGroup(frontGroupId)) {
    if (c.name.toLowerCase().contains(q)) return true;
    if (c.searchAliases.any((a) => a.toLowerCase().contains(q))) return true;
    if (c.subServices.any((s) => s.toLowerCase().contains(q))) return true;
  }
  return false;
}

/// [ServiceFrontGroupIds.orderedIds] filtered by search (preserves order).
List<String> matchingFrontGroupIds(String query) {
  final q = query.trim();
  if (q.isEmpty) return List<String>.from(ServiceFrontGroupIds.orderedIds);
  return ServiceFrontGroupIds.orderedIds
      .where((id) => frontGroupMatchesQuery(id, q))
      .toList();
}

/// Category to open when tapping a front-group row on **All services** —
/// first category that matches [query], else the hub anchor (T2).
String? primaryCategoryIdForFrontGroupTap(
  String frontGroupId,
  String query,
) {
  final q = query.trim().toLowerCase();
  final anchor = ServiceFrontGroupLabels.anchorCategoryId(frontGroupId);
  if (q.isEmpty) return anchor;

  final fgLabel =
      ServiceFrontGroupLabels.labelEnglish(frontGroupId)?.toLowerCase();
  if (fgLabel != null && fgLabel.contains(q)) return anchor;

  for (final c in categoriesForFrontGroup(frontGroupId)) {
    if (c.name.toLowerCase().contains(q)) return c.id;
    if (c.searchAliases.any((a) => a.toLowerCase().contains(q))) return c.id;
    if (c.subServices.any((s) => s.toLowerCase().contains(q))) return c.id;
  }
  return anchor;
}

/// Up to [max] sub-service preview strings for the All services list (search-aware).
String previewLeavesForFrontGroup(
  String frontGroupId,
  String query, {
  int max = 3,
}) {
  final q = query.trim().toLowerCase();
  final cats = categoriesForFrontGroup(frontGroupId);
  final out = <String>[];

  void addUnique(String s) {
    if (out.length >= max) return;
    if (s.trim().isEmpty) return;
    if (!out.contains(s)) out.add(s);
  }

  if (q.isEmpty) {
    for (final c in cats) {
      for (final sub in c.subServices) {
        addUnique(sub);
        if (out.length >= max) return out.join(' · ');
      }
    }
    return out.join(' · ');
  }

  for (final c in cats) {
    for (final sub in c.subServices) {
      if (sub.toLowerCase().contains(q)) addUnique(sub);
      if (out.length >= max) return out.join(' · ');
    }
  }
  if (out.isNotEmpty) return out.join(' · ');

  for (final c in cats) {
    for (final sub in c.subServices) {
      addUnique(sub);
      if (out.length >= max) return out.join(' · ');
    }
  }
  return out.join(' · ');
}

List<ServiceSearchHit> searchServiceTaxonomy(String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return const [];

  final hits = <ServiceSearchHit>[];
  final seen = <String>{};

  for (final category in kServiceCategories) {
    final fgLabel = ServiceFrontGroupLabels.labelEnglish(category.frontGroupId);
    final fgMatches = fgLabel != null && fgLabel.toLowerCase().contains(trimmed);
    final categoryMatches = category.name.toLowerCase().contains(trimmed);
    final aliasMatches = category.searchAliases.any(
      (a) => a.toLowerCase().contains(trimmed),
    );
    final categoryOrGroupMatches =
        categoryMatches || fgMatches || aliasMatches;

    for (final sub in category.subServices) {
      if (categoryOrGroupMatches || sub.toLowerCase().contains(trimmed)) {
        final key = '${category.id}::$sub';
        if (seen.add(key)) {
          hits.add(ServiceSearchHit(category: category, subService: sub));
        }
      }
    }
  }
  return hits;
}

/// Deferred — live provider matching, availability, and automated dispatch.
/// MVP stores leads in Firestore and hands off via WhatsApp only.
