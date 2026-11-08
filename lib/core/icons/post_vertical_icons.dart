import 'package:flutter/material.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

/// Post Engine icon mapping — Material outlined icons aligned with [RaabtaIcons].
abstract final class PostVerticalIcons {
  static IconData forVertical(PostVertical vertical) => switch (vertical) {
        PostVertical.housing => Icons.home_outlined,
        PostVertical.jobs => Icons.work_outline_rounded,
        PostVertical.business => Icons.storefront_outlined,
        PostVertical.services => Icons.handyman_outlined,
        PostVertical.marketplace => Icons.shopping_bag_outlined,
      };

  static IconData forCategoryId(String categoryId) {
    final id = categoryId.toLowerCase();
    if (id.contains('vehicle') || id.contains('car')) {
      return Icons.directions_car_outlined;
    }
    if (id.contains('electronic') || id.contains('mobile')) {
      return Icons.smartphone_outlined;
    }
    if (id.contains('housing') || id.contains('room') || id.contains('flat')) {
      return Icons.home_outlined;
    }
    if (id.contains('job')) return Icons.work_outline_rounded;
    if (id.contains('business') || id.contains('restaurant')) {
      return Icons.storefront_outlined;
    }
    if (id.contains('service') || id.contains('clean')) {
      return Icons.handyman_outlined;
    }
    return Icons.category_outlined;
  }
}
