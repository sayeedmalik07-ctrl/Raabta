import 'package:flutter/material.dart';

/// Icons for bottom-nav hub tabs (Marketplace, Community, AI).
abstract final class HubScreenIcons {
  static IconData marketplaceCategory(String categoryId) => switch (categoryId) {
        'cars_bikes' => Icons.directions_car_outlined,
        'mobiles_tablets' => Icons.smartphone_outlined,
        'furniture' => Icons.weekend_outlined,
        'electronics' => Icons.devices_outlined,
        'home_appliances' => Icons.kitchen_outlined,
        'books_more' => Icons.menu_book_outlined,
        _ => Icons.category_outlined,
      };

  static const marketplace = Icons.shopping_bag_outlined;
  static const community = Icons.groups_outlined;
  static const ai = Icons.auto_awesome_outlined;
}
