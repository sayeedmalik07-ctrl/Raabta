import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Visual identity for a service subcategory — gradient badge + icon.
class ServiceSubcategoryVisual {
  const ServiceSubcategoryVisual({
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
}

/// Resolves premium icon + gradient for taxonomy sub-services.
abstract final class ServiceSubcategoryVisuals {
  static const _categoryPalettes = <String, List<Color>>{
    'home_cleaning': [AppColors.cyanGlow, AppColors.tealGlow],
    'home_maintenance': [AppColors.blueGlow, AppColors.purpleGlow],
    'pest_control': [AppColors.emeraldGlow, AppColors.tealGlow],
    'home_healthcare': [AppColors.roseGlow, AppColors.purpleGlow],
    'childcare': [AppColors.pinkAccent, AppColors.purpleGlow],
    'education': [AppColors.quickActionIndigo, AppColors.blueGlow],
    'beauty_wellness': [AppColors.pinkAccent, AppColors.amberGlow],
    'moving_services': [AppColors.quickActionBlue, AppColors.cyanGlow],
    'laundry': [AppColors.iceCyanGlow, AppColors.blueGlow],
    'automotive': [AppColors.amberGlow, AppColors.heatOrange],
    'electronics_repair': [AppColors.purpleGlow, AppColors.cyanGlow],
    'appliance_repair': [AppColors.tealGlow, AppColors.emeraldGlow],
    'outdoor_services': [AppColors.emeraldGlow, AppColors.quickActionGreen],
    'event_services': [AppColors.accentGold, AppColors.pinkAccent],
    'business_services': [AppColors.sharePurple, AppColors.blueGlow],
    'pet_services': [AppColors.quickActionYellow, AppColors.amberGlow],
    'digital_services': [AppColors.cyanGlow, AppColors.quickActionIndigo],
    'professional_services': [AppColors.sharePurpleLight, AppColors.purpleGlow],
    'home_installation': [AppColors.blueGlow, AppColors.cyanGlow],
    'security_services': [AppColors.quickActionIndigo, AppColors.purpleGlow],
    'religious_services': [AppColors.tealGlow, AppColors.emeraldGlow],
    'travel_lifestyle': [AppColors.cyanGlow, AppColors.blueGlow],
    'freelancers': [AppColors.purpleGlow, AppColors.pinkAccent],
    'emergency_services': [AppColors.error, AppColors.heatOrange],
  };

  static ServiceSubcategoryVisual forSubservice({
    required String categoryId,
    required String subServiceName,
  }) {
    final palette = _categoryPalettes[categoryId] ??
        [AppColors.cyanGlow, AppColors.purpleGlow];
    final icon = _iconForName(subServiceName);
    final shift = subServiceName.hashCode.abs() % 3;
    final gradient = [
      palette[shift % palette.length],
      palette[(shift + 1) % palette.length],
    ];
    return ServiceSubcategoryVisual(
      icon: icon,
      gradient: gradient,
      glowColor: gradient.first,
    );
  }

  static ServiceSubcategoryVisual forAll() {
    return ServiceSubcategoryVisual(
      icon: Icons.grid_view_rounded,
      gradient: [AppColors.brandFamilyMain, AppColors.purpleGlow],
      glowColor: AppColors.brandFamilyMain,
    );
  }

  static ServiceSubcategoryVisual forCategory({
    required String categoryId,
    required IconData icon,
  }) {
    final palette = _categoryPalettes[categoryId] ??
        [AppColors.brandFamilyMain, AppColors.purpleGlow];
    return ServiceSubcategoryVisual(
      icon: icon,
      gradient: [AppColors.brandFamilyMain, palette.last],
      glowColor: AppColors.brandFamilyMain,
    );
  }

  static IconData _iconForName(String name) {
    final n = name.toLowerCase();

    if (n.contains('clean') || n.contains('sanitiz') || n.contains('wash')) {
      return Icons.cleaning_services_rounded;
    }
    if (n.contains('ac ') || n.startsWith('ac ') || n.contains('air cond')) {
      return Icons.ac_unit_rounded;
    }
    if (n.contains('plumb') || n.contains('pipe') || n.contains('water tank')) {
      return Icons.plumbing_rounded;
    }
    if (n.contains('electric') || n.contains('wiring')) {
      return Icons.electrical_services_rounded;
    }
    if (n.contains('paint')) return Icons.format_paint_rounded;
    if (n.contains('carpent') || n.contains('furniture') || n.contains('door') ||
        n.contains('lock') || n.contains('ceiling') || n.contains('tile') ||
        n.contains('gypsum') || n.contains('handyman')) {
      return Icons.handyman_rounded;
    }
    if (n.contains('pest') || n.contains('cockroach') || n.contains('termite') ||
        n.contains('rodent') || n.contains('mosquito') || n.contains('disinfect')) {
      return Icons.pest_control_rounded;
    }
    if (n.contains('nurse') || n.contains('care') || n.contains('doctor') ||
        n.contains('physio') || n.contains('medical') || n.contains('blood')) {
      return Icons.medical_services_rounded;
    }
    if (n.contains('baby') || n.contains('nanny') || n.contains('child') ||
        n.contains('infant')) {
      return Icons.child_care_rounded;
    }
    if (n.contains('tuition') || n.contains('teacher') || n.contains('coach') ||
        n.contains('lesson') || n.contains('coding') || n.contains('robotics') ||
        n.contains('quran') || n.contains('arabic') || n.contains('english') ||
        n.contains('ielts')) {
      return Icons.school_rounded;
    }
    if (n.contains('salon') || n.contains('hair') || n.contains('makeup') ||
        n.contains('bridal') || n.contains('nail') || n.contains('facial') ||
        n.contains('massage') || n.contains('spa') || n.contains('yoga') ||
        n.contains('trainer')) {
      return Icons.spa_rounded;
    }
    if (n.contains('shift') || n.contains('moving') || n.contains('pack') ||
        n.contains('storage') || n.contains('disposal')) {
      return Icons.local_shipping_rounded;
    }
    if (n.contains('laundry') || n.contains('dry clean') || n.contains('iron') ||
        n.contains('shoe') || n.contains('bag clean')) {
      return Icons.local_laundry_service_rounded;
    }
    if (n.contains('car') || n.contains('vehicle') || n.contains('tyre') ||
        n.contains('battery') || n.contains('oil') || n.contains('towing') ||
        n.contains('detailing')) {
      return Icons.directions_car_rounded;
    }
    if (n.contains('mobile') || n.contains('laptop') || n.contains('computer') ||
        n.contains('printer') || n.contains('tv') || n.contains('cctv') ||
        n.contains('wifi') || n.contains('smart home')) {
      return Icons.devices_rounded;
    }
    if (n.contains('refrigerator') || n.contains('washing') ||
        n.contains('dishwasher') || n.contains('microwave') || n.contains('oven') ||
        n.contains('dispenser') || n.contains('heater')) {
      return Icons.kitchen_rounded;
    }
    if (n.contains('garden') || n.contains('lawn') || n.contains('landscape') ||
        n.contains('tree') || n.contains('irrigation') || n.contains('pool')) {
      return Icons.yard_rounded;
    }
    if (n.contains('photo') || n.contains('video') || n.contains('cater') ||
        n.contains('decor') || n.contains('wedding') || n.contains('birthday') ||
        n.contains('sound') || n.contains('dj') || n.contains('event')) {
      return Icons.celebration_rounded;
    }
    if (n.contains('office') || n.contains('reception') || n.contains('printing') ||
        n.contains('translation') || n.contains('pro service')) {
      return Icons.business_center_rounded;
    }
    if (n.contains('pet') || n.contains('dog') || n.contains('veterinary')) {
      return Icons.pets_rounded;
    }
    if (n.contains('design') || n.contains('website') || n.contains('app dev') ||
        n.contains('marketing') || n.contains('seo') || n.contains('content')) {
      return Icons.computer_rounded;
    }
    if (n.contains('lawyer') || n.contains('accountant') || n.contains('tax') ||
        n.contains('insurance') || n.contains('consultant')) {
      return Icons.work_rounded;
    }
    if (n.contains('curtain') || n.contains('blind') || n.contains('wallpaper') ||
        n.contains('mount') || n.contains('shelv') || n.contains('filter')) {
      return Icons.home_repair_service_rounded;
    }
    if (n.contains('security') || n.contains('cctv') || n.contains('alarm') ||
        n.contains('access control')) {
      return Icons.security_rounded;
    }
    if (n.contains('islamic') || n.contains('hajj') || n.contains('umrah')) {
      return Icons.menu_book_rounded;
    }
    if (n.contains('airport') || n.contains('chauffeur') || n.contains('driver') ||
        n.contains('tour') || n.contains('shopper')) {
      return Icons.flight_rounded;
    }
    if (n.contains('emergency') || n.contains('locksmith')) {
      return Icons.emergency_rounded;
    }
    if (n.contains('window') || n.contains('sofa') || n.contains('carpet') ||
        n.contains('mattress') || n.contains('curtain clean') ||
        n.contains('kitchen clean') || n.contains('bathroom')) {
      return Icons.cleaning_services_rounded;
    }
    if (n.contains('passport') || n.contains('visa') || n.contains('license') ||
        n.contains('driving')) {
      return Icons.badge_rounded;
    }

    return Icons.home_repair_service_rounded;
  }
}
