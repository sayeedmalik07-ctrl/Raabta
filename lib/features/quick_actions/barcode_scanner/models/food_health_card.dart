import 'package:flutter/material.dart';

import 'halal_product_info.dart';

class NutrientInfo {
  final String name;
  final String amount;
  final double per100g;
  final double dailyPct;

  const NutrientInfo({
    required this.name,
    required this.amount,
    required this.per100g,
    required this.dailyPct,
  });
}

class DecodedAdditive {
  final String code;
  final String plainName;
  final String status;
  final String reason;

  const DecodedAdditive({
    required this.code,
    required this.plainName,
    required this.status,
    required this.reason,
  });
}

class FoodHealthCard {
  final String barcode;
  final String productName;
  final String brand;
  final String? imageUrl;
  final int healthScore;
  final String verdict;
  final Color verdictColor;
  final String motivationalMessage;
  final String summary;
  final List<NutrientInfo> nutrients;
  final List<DecodedAdditive> additives;
  final String language;
  final List<String> allergyWarnings;
  final HalalProductInfo halalInfo;

  const FoodHealthCard({
    required this.barcode,
    required this.productName,
    required this.brand,
    this.imageUrl,
    required this.healthScore,
    required this.verdict,
    required this.verdictColor,
    required this.motivationalMessage,
    required this.summary,
    required this.nutrients,
    required this.additives,
    required this.language,
    this.allergyWarnings = const [],
    this.halalInfo = HalalProductInfo.empty,
  });
}
