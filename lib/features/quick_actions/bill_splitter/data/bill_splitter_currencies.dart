import 'package:raabta/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:raabta/services/exchange_rate_service.dart';

abstract final class BillSplitterCurrencies {
  static const codes = billSplitterCurrencyCodes;

  static const symbols = {
    'INR': '₹',
    'PHP': '₱',
    'GBP': '£',
    'USD': '\$',
    'EUR': '€',
    'BDT': '৳',
    'PKR': '₨',
    'EGP': 'E£',
    'LKR': 'Rs',
    'NPR': 'रू',
    'KES': 'KSh',
    'MYR': 'RM',
    'SGD': 'S\$',
    'AED': 'د.إ',
    'SAR': '﷼',
  };

  static const flags = {
    'INR': '🇮🇳',
    'PHP': '🇵🇭',
    'GBP': '🇬🇧',
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'BDT': '🇧🇩',
    'PKR': '🇵🇰',
    'EGP': '🇪🇬',
    'LKR': '🇱🇰',
    'NPR': '🇳🇵',
    'KES': '🇰🇪',
    'MYR': '🇲🇾',
    'SGD': '🇸🇬',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
  };

  static const accentColors = {
    'INR': Color(0xFFFF9933),
    'PHP': Color(0xFF0038A8),
    'GBP': Color(0xFF012169),
    'USD': Color(0xFF3C3B6E),
    'EUR': Color(0xFF003399),
    'BDT': Color(0xFF006A4E),
    'PKR': Color(0xFF01411C),
    'EGP': Color(0xFFCE1126),
    'LKR': Color(0xFF8D153A),
    'NPR': Color(0xFF003893),
    'KES': Color(0xFF006600),
    'MYR': Color(0xFFCC0001),
    'SGD': Color(0xFFEF3340),
    'AED': Color(0xFF00732F),
    'SAR': Color(0xFF006C35),
  };

  static String symbolFor(String code) => symbols[code] ?? code;

  static String flagFor(String code) => flags[code] ?? '🌍';

  static Color colorFor(String code) =>
      accentColors[code] ?? AppColors.sharePurple;

  static String formatHomeAmount(String currency, double qar, double rate) {
    final symbol = symbolFor(currency);
    final converted = qar * rate;
    if (converted >= 1000) {
      return '$symbol${(converted / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${converted.toStringAsFixed(0)}';
  }
}
