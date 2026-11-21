import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

/// Parsed bill fields returned from the RAABTA OCR → extraction pipeline.
class ScannedBillData {
  const ScannedBillData({
    this.provider,
    this.billType,
    this.amount,
    this.dueDate,
    this.accountNumber,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.currency,
    required this.confidenceLevel,
    required this.confidence,
    this.ocrText,
    this.sourceImagePath,
    this.sourcePdfPath,
  });

  final String? provider;
  final String? billType;
  final double? amount;
  final DateTime? dueDate;
  final String? accountNumber;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final String? currency;
  final BillExtractionConfidence confidenceLevel;
  final double confidence;
  final String? ocrText;
  final String? sourceImagePath;
  final String? sourcePdfPath;

  bool get isHighConfidence =>
      confidenceLevel == BillExtractionConfidence.high;
  bool get isMediumConfidence =>
      confidenceLevel == BillExtractionConfidence.medium;
  bool get isLowConfidence => confidenceLevel == BillExtractionConfidence.low;

  bool get shouldPrefill =>
      confidenceLevel != BillExtractionConfidence.low;

  Color get confidenceColor {
    if (isHighConfidence) return AppColors.successBright;
    if (isMediumConfidence) return AppColors.accentGold;
    return AppColors.errorBright;
  }

  String confidenceLabelFor(String locale) =>
      BillTrackerStrings.scanConfidenceLabel(confidence, locale);

  factory ScannedBillData.fromExtraction(
    BillExtractionResult result, {
    String? ocrText,
    String? sourceImagePath,
    String? sourcePdfPath,
  }) {
    return ScannedBillData(
      provider: result.provider,
      billType: result.billType,
      amount: result.amount,
      dueDate: result.dueDate,
      accountNumber: result.accountNumber,
      billingPeriodStart: result.billingPeriodStart,
      billingPeriodEnd: result.billingPeriodEnd,
      currency: result.currency,
      confidenceLevel: result.confidenceLevel,
      confidence: result.confidence,
      ocrText: ocrText,
      sourceImagePath: sourceImagePath,
      sourcePdfPath: sourcePdfPath,
    );
  }
}
