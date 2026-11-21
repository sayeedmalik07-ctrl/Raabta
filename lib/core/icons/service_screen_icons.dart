import 'package:flutter/material.dart';

/// Curated icons for service sub-screens (visa categories, health actions, etc.).
abstract final class ServiceScreenIcons {
  static IconData visaCategory(String categoryId) => switch (categoryId) {
        'iqama_renewal' => Icons.description_outlined,
        'exit_permit' => Icons.flight_takeoff_rounded,
        'family_visa' => Icons.family_restroom_outlined,
        'sponsor_transfer' => Icons.swap_horiz_rounded,
        'medical' => Icons.local_hospital_outlined,
        'qatar_id' => Icons.badge_outlined,
        _ => Icons.article_outlined,
      };

  static const healthActions = <String, IconData>{
    'finder': Icons.local_hospital_outlined,
    'medicines': Icons.medication_outlined,
    'records': Icons.folder_copy_outlined,
    'trackers': Icons.monitor_heart_outlined,
    'upload_lab': Icons.biotech_outlined,
    'emergency': Icons.emergency_outlined,
    'ai_insights': Icons.auto_awesome_outlined,
  };

  static IconData trendingLocation(String name) => switch (name) {
        'Al Khor' => Icons.location_city_outlined,
        'Doha' => Icons.apartment_outlined,
        'Lusail' => Icons.star_outline_rounded,
        'The Pearl' => Icons.beach_access_outlined,
        'Al Wakrah' => Icons.home_work_outlined,
        _ => Icons.place_outlined,
      };

  static IconData jobBenefit(String benefit) {
    final lower = benefit.toLowerCase();
    if (lower.contains('flight')) return Icons.flight_outlined;
    if (lower.contains('housing') || lower.contains('house')) {
      return Icons.home_outlined;
    }
    if (lower.contains('medical')) return Icons.local_hospital_outlined;
    return Icons.check_circle_outline;
  }
}
