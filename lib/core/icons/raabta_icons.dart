import 'package:flutter/material.dart';

/// Curated outlined icon set for Raabta home shortcuts — consistent 24px grid.
abstract final class RaabtaIcons {
  static const gridSize = 24.0;

  static const quickActions = <IconData>[
    Icons.work_outline_rounded,
    Icons.home_outlined,
    Icons.shopping_bag_outlined,
    Icons.handyman_outlined,
    Icons.campaign_outlined,
  ];

  static const explore = <IconData>[
    Icons.home_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.description_outlined,
    Icons.work_outline_rounded,
    Icons.handyman_outlined,
    Icons.storefront_outlined,
  ];

  static const exploreRoutes = <String>[
    '/housing',
    '/money',
    '/visa',
    '/jobs',
    '/services',
    '/businesses',
  ];

  static IconData forRoute(String route) {
    final idx = exploreRoutes.indexOf(route);
    if (idx >= 0) return explore[idx];
    return switch (route) {
      '/marketplace' => Icons.shopping_bag_outlined,
      '/ai-chat' => Icons.auto_awesome_outlined,
      '/eosb' => Icons.balance_outlined,
      '/trip-planner' => Icons.flight_takeoff_rounded,
      '/prayer-mosque' => Icons.mosque_outlined,
      '/scanner' => Icons.document_scanner_outlined,
      '/scanner/capture' => Icons.document_scanner_outlined,
      '/document-vault' => Icons.folder_copy_outlined,
      '/barcode-scanner' => Icons.qr_code_scanner_rounded,
      '/arabic-companion' => Icons.translate_rounded,
      '/landmark-translator' => Icons.translate_rounded,
      '/bill-splitter' => Icons.receipt_long_outlined,
      '/warranty-shield' => Icons.verified_user_outlined,
      '/climate-navigator' => Icons.ac_unit_outlined,
      '/queue-avoidance' => Icons.hourglass_top_outlined,
      '/bill-tracker' => Icons.receipt_outlined,
      '/ramadan' => Icons.nightlight_round,
      '/daily-ussd' => Icons.sim_card_outlined,
      '/daily-phrases' => Icons.translate_rounded,
      '/driving' => Icons.directions_car_outlined,
      '/services' => Icons.handyman_outlined,
      _ => Icons.apps_outlined,
    };
  }
}
