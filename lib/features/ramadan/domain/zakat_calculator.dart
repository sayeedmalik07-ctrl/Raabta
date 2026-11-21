import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';

enum NisabStandard { gold, silver }

class ZakatInputs {
  const ZakatInputs({
    this.cashQar = 0,
    this.goldWeightGrams = 0,
    this.goldPurity = 24,
    this.useLockerGold = false,
    this.lockerGoldValueQar = 0,
    this.silverWeightGrams = 0,
    this.silverPurity = 999,
    this.investmentsQar = 0,
    this.businessInventoryQar = 0,
    this.debtsReceivableQar = 0,
    this.debtsPayableQar = 0,
    this.nisabStandard = NisabStandard.gold,
    this.silverPricePerGramQar,
  });

  final double cashQar;
  final double goldWeightGrams;
  final int goldPurity;
  final bool useLockerGold;
  final double lockerGoldValueQar;
  final double silverWeightGrams;
  final int silverPurity;
  final double investmentsQar;
  final double businessInventoryQar;
  final double debtsReceivableQar;
  final double debtsPayableQar;
  final NisabStandard nisabStandard;
  final double? silverPricePerGramQar;
}

class ZakatBreakdownSegment {
  const ZakatBreakdownSegment({
    required this.labelKey,
    required this.amount,
    required this.color,
  });

  final String labelKey;
  final double amount;
  final Color color;
}

class ZakatResult {
  const ZakatResult({
    required this.cashQar,
    required this.goldValueQar,
    required this.silverValueQar,
    required this.investmentsQar,
    required this.businessInventoryQar,
    required this.debtsReceivableQar,
    required this.debtsPayableQar,
    required this.zakatableWealth,
    required this.nisabThreshold,
    required this.meetsNisab,
    required this.zakatDue,
    required this.nisabStandard,
    required this.goldRatePerGram,
    required this.silverRatePerGram,
    required this.rateUpdatedAt,
    required this.segments,
  });

  final double cashQar;
  final double goldValueQar;
  final double silverValueQar;
  final double investmentsQar;
  final double businessInventoryQar;
  final double debtsReceivableQar;
  final double debtsPayableQar;
  final double zakatableWealth;
  final double nisabThreshold;
  final bool meetsNisab;
  final double zakatDue;
  final NisabStandard nisabStandard;
  final double goldRatePerGram;
  final double silverRatePerGram;
  final DateTime? rateUpdatedAt;
  final List<ZakatBreakdownSegment> segments;
}

/// Pure Dart Zakat arithmetic — no AI, not a religious ruling.
abstract final class ZakatCalculatorEngine {
  static const goldNisabGrams = 85.0;
  static const silverNisabGrams = 595.0;
  static const zakatRate = 0.025;
  static const defaultSilverQarPerGram = 3.25;

  static double lockerGoldValue(
    List<JewelryLockerItem> items,
    double price24k,
  ) {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.estimatedValueQar(price24k),
    );
  }

  static ZakatResult compute({
    required ZakatInputs inputs,
    required double gold24kQarPerGram,
    DateTime? rateUpdatedAt,
  }) {
    final goldRate = gold24kQarPerGram > 0 ? gold24kQarPerGram : 280.0;
    final silverRate = inputs.silverPricePerGramQar ?? defaultSilverQarPerGram;

    final manualGoldValue = inputs.goldWeightGrams > 0
        ? GoldQatarConstants.priceForPurity(goldRate, inputs.goldPurity) *
            inputs.goldWeightGrams
        : 0.0;
    final goldValue = inputs.useLockerGold && inputs.lockerGoldValueQar > 0
        ? inputs.lockerGoldValueQar
        : manualGoldValue;

    final silverValue = inputs.silverWeightGrams > 0
        ? silverRate * inputs.silverWeightGrams * (inputs.silverPurity / 1000)
        : 0.0;

    final grossWealth = inputs.cashQar +
        goldValue +
        silverValue +
        inputs.investmentsQar +
        inputs.businessInventoryQar +
        inputs.debtsReceivableQar;

    final zakatableWealth = (grossWealth - inputs.debtsPayableQar)
        .clamp(0.0, double.infinity)
        .toDouble();

    final nisabThreshold = inputs.nisabStandard == NisabStandard.gold
        ? goldNisabGrams * goldRate
        : silverNisabGrams * silverRate;

    final meetsNisab = nisabThreshold > 0 && zakatableWealth >= nisabThreshold;
    final zakatDue = meetsNisab ? zakatableWealth * zakatRate : 0.0;

    final segments = <ZakatBreakdownSegment>[
      if (inputs.cashQar > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_cash',
          amount: inputs.cashQar,
          color: AppColors.cyanGlow,
        ),
      if (goldValue > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_gold',
          amount: goldValue,
          color: AppColors.accentGold,
        ),
      if (silverValue > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_silver',
          amount: silverValue,
          color: AppColors.textSecondary,
        ),
      if (inputs.investmentsQar > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_investments',
          amount: inputs.investmentsQar,
          color: AppColors.emeraldGlow,
        ),
      if (inputs.businessInventoryQar > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_business',
          amount: inputs.businessInventoryQar,
          color: AppColors.sharePurple,
        ),
      if (inputs.debtsReceivableQar > 0)
        ZakatBreakdownSegment(
          labelKey: 'zakat_seg_receivable',
          amount: inputs.debtsReceivableQar,
          color: AppColors.info,
        ),
    ];

    return ZakatResult(
      cashQar: inputs.cashQar,
      goldValueQar: goldValue,
      silverValueQar: silverValue,
      investmentsQar: inputs.investmentsQar,
      businessInventoryQar: inputs.businessInventoryQar,
      debtsReceivableQar: inputs.debtsReceivableQar,
      debtsPayableQar: inputs.debtsPayableQar,
      zakatableWealth: zakatableWealth,
      nisabThreshold: nisabThreshold,
      meetsNisab: meetsNisab,
      zakatDue: zakatDue,
      nisabStandard: inputs.nisabStandard,
      goldRatePerGram: goldRate,
      silverRatePerGram: silverRate,
      rateUpdatedAt: rateUpdatedAt,
      segments: segments,
    );
  }
}
