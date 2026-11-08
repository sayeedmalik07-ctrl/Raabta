import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodScanHistoryEntry {
  const FoodScanHistoryEntry({
    required this.barcode,
    required this.productName,
    required this.healthScore,
    required this.scoreColorArgb,
    required this.savedAt,
  });

  final String barcode;
  final String productName;
  final int healthScore;
  final int scoreColorArgb;
  final DateTime savedAt;

  Color get scoreColor => Color(scoreColorArgb);

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'productName': productName,
        'healthScore': healthScore,
        'scoreColorArgb': scoreColorArgb,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FoodScanHistoryEntry.fromJson(Map<String, dynamic> json) {
    return FoodScanHistoryEntry(
      barcode: json['barcode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      healthScore: json['healthScore'] as int? ?? 0,
      scoreColorArgb: json['scoreColorArgb'] as int? ?? 0xFF9C27B0,
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

abstract final class FoodScanHistoryRepository {
  static const _key = 'food_scan_history_v1';
  static const _maxEntries = 5;

  static Future<List<FoodScanHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => FoodScanHistoryEntry.fromJson(e as Map<String, dynamic>),
          )
          .where((e) => e.barcode.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> save({
    required String barcode,
    required String productName,
    required int healthScore,
    required Color scoreColor,
  }) async {
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isEmpty) return;

    final existing = await load();
    final updated = [
      FoodScanHistoryEntry(
        barcode: trimmedBarcode,
        productName: productName,
        healthScore: healthScore,
        scoreColorArgb: scoreColor.toARGB32(),
        savedAt: DateTime.now(),
      ),
      ...existing.where((e) => e.barcode != trimmedBarcode),
    ].take(_maxEntries).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}
