import 'package:raabta/data/models/category_filter.dart';

import 'package:raabta/features/business/domain/business_category_catalog.dart';

/// Business directory browse filters — [filter] values match post_schemas leaf ids.
const List<CategoryFilter> kBusinessCategories = [
  CategoryFilter(label: 'All', emoji: '🔍'),
  CategoryFilter(label: 'Iftar Deals', emoji: '🌙', filter: 'ramadan_iftar'),
  CategoryFilter(
    label: 'Restaurants',
    emoji: '🍛',
    filter: 'restaurant',
  ),
  CategoryFilter(label: 'Salons', emoji: '✂️', filter: 'salon'),
  CategoryFilter(label: 'Gyms', emoji: '🏋️', filter: 'gym'),
  CategoryFilter(label: 'Clinics', emoji: '🏥', filter: 'clinic'),
  CategoryFilter(label: 'AC & Repair', emoji: '🔧', filter: 'ac_repair'),
  CategoryFilter(label: 'Grocery', emoji: '🛒', filter: 'grocery'),
  CategoryFilter(label: 'Travel', emoji: '✈️', filter: 'travel'),
  CategoryFilter(label: 'PRO Services', emoji: '📋', filter: 'pro_services'),
];

/// User-facing label for a business category leaf id.
String businessCategoryDisplayLabel(String leafId) =>
    BusinessCategoryCatalog.displayLabel(leafId);
