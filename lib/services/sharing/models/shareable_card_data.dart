import 'package:flutter/material.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_presentation_builder.dart';

// ─── Card type enum ───────────────────────────────────────

enum ShareableCardType {
  healthScore,    // Food Inspector
  billSplit,      // Bill Splitter
  warrantyAlert,  // Warranty Shield
  waitTime,       // Queue Avoidance
  documentAlert,  // Document Vault
  eosbSettlement, // EOSB Truth Engine
  eosbTruthCertificate, // EOSB Truth Certificate (Phase 1)
  overtimeTruth, // EOSB Overtime Truth Engine
  friendsFamilyLoan, // Bill Tracker — Friends & Family loans
  healthInsuranceCompliance, // Health Insurance Truth Engine — compliance
  healthInsurancePolicy, // Health Insurance Truth Engine — policy explainer
  healthInsuranceDenial, // Health Insurance Truth Engine — claim denial dispute
  tripItinerary,  // Trip Planner
  prayerTimes,    // Islamic Companion
  personalBudget, // Money Hub — Personal Budget snapshot
  utilityBills, // Bill Tracker — utility bills outstanding summary
}

// ─── Base card data ───────────────────────────────────────

abstract class ShareableCardData {
  final ShareableCardType type;
  final String shareCaption; // Text sent alongside the image
  /// When set (EOSB/Overtime shares), QR footer points here instead of homepage.
  final String? referralLinkUrl;

  const ShareableCardData({
    required this.type,
    required this.shareCaption,
    this.referralLinkUrl,
  });
}

// ─── 1. Health Score Card ─────────────────────────────────
// Source: Food Inspector scan result

class HealthScoreCardData extends ShareableCardData {
  final String productName;
  final String brand;
  final String? productImageUrl;
  final int healthScore;           // 0-100
  final String verdict;            // Excellent/Good/etc
  final Color verdictColor;
  final String motivationalMessage;
  final List<NutrientRow> topNutrients; // max 4
  final List<AdditiveRow> topAdditives; // max 3
  final HalalShareSnapshot halalSnapshot;
  final List<String> allergyWarnings;
  final String language;

  const HealthScoreCardData({
    required this.productName,
    required this.brand,
    this.productImageUrl,
    required this.healthScore,
    required this.verdict,
    required this.verdictColor,
    required this.motivationalMessage,
    required this.topNutrients,
    required this.topAdditives,
    required this.halalSnapshot,
    required this.allergyWarnings,
    required this.language,
    required super.shareCaption,
  }) : super(type: ShareableCardType.healthScore);
}

class NutrientRow {
  final String name;
  final String amount;
  final double dailyPct;
  const NutrientRow({
    required this.name,
    required this.amount,
    required this.dailyPct,
  });
}

class AdditiveRow {
  final String code;
  final String plainName;
  final String status; // safe/caution/avoid
  const AdditiveRow({
    required this.code,
    required this.plainName,
    required this.status,
  });
}

/// Community halal label data for share cards — not a certification verdict.
class HalalShareSnapshot {
  const HalalShareSnapshot({
    required this.communityLabels,
    required this.hasCommunityData,
  });

  final List<String> communityLabels;
  final bool hasCommunityData;
}

// ─── 2. Bill Split Card ───────────────────────────────────
// Source: Bill Splitter group summary

class BillSplitCardData extends ShareableCardData {
  final double totalQar;
  final double taxPercent;
  final List<SplitPersonRow> people;
  final String? groupName;         // null for one-time splits
  final bool isRecurring;

  const BillSplitCardData({
    required this.totalQar,
    required this.taxPercent,
    required this.people,
    this.groupName,
    required this.isRecurring,
    required super.shareCaption,
  }) : super(type: ShareableCardType.billSplit);
}

class SplitPersonRow {
  final String name;
  final String flag;
  final String currency;
  final String formattedHomeAmount; // e.g. "₹2,077"
  final double shareQar;
  const SplitPersonRow({
    required this.name,
    required this.flag,
    required this.currency,
    required this.formattedHomeAmount,
    required this.shareQar,
  });
}

// ─── 3. Warranty Alert Card ───────────────────────────────
// Source: Warranty Shield item approaching expiry

class WarrantyAlertCardData extends ShareableCardData {
  final String productName;
  final String brand;
  final String category;
  final int daysLeft;
  final DateTime expiryDate;
  final double purchasePriceQar;
  final bool isExpired;

  const WarrantyAlertCardData({
    required this.productName,
    required this.brand,
    required this.category,
    required this.daysLeft,
    required this.expiryDate,
    required this.purchasePriceQar,
    required this.isExpired,
    required super.shareCaption,
  }) : super(type: ShareableCardType.warrantyAlert);
}

// ─── 4. Wait Time Card ────────────────────────────────────
// Source: Queue Avoidance prediction result

class WaitTimeCardData extends ShareableCardData {
  final String locationName;
  final String locationArea;
  final String locationEmoji;
  final int estimatedMinutes;
  final String currentStatus;    // Quiet/Moderate/Busy/etc
  final Color statusColor;
  final String bestTimeToVisit;
  final String reportedAt;       // e.g. "Just now"
  final int communityReportCount;

  const WaitTimeCardData({
    required this.locationName,
    required this.locationArea,
    required this.locationEmoji,
    required this.estimatedMinutes,
    required this.currentStatus,
    required this.statusColor,
    required this.bestTimeToVisit,
    required this.reportedAt,
    required this.communityReportCount,
    required super.shareCaption,
  }) : super(type: ShareableCardType.waitTime);
}

// ─── 5. Document Alert Card ───────────────────────────────
// Source: Document Vault expiry warning

class DocumentAlertCardData extends ShareableCardData {
  final String docType;          // QID / Passport / Visa etc
  final String docTypeEmoji;
  final String holderName;
  final int daysLeft;
  final DateTime expiryDate;
  final bool isExpired;
  final Color urgencyColor;

  const DocumentAlertCardData({
    required this.docType,
    required this.docTypeEmoji,
    required this.holderName,
    required this.daysLeft,
    required this.expiryDate,
    required this.isExpired,
    required this.urgencyColor,
    required super.shareCaption,
  }) : super(type: ShareableCardType.documentAlert);
}

// ─── 6. EOSB Settlement Card ──────────────────────────────

class EosbSettlementCardData extends ShareableCardData {
  final double estimatedEosb;
  final int confidenceScore;
  final double? employerOffer;
  final double? difference;
  final bool isUnderpaid;
  final DateTime calculatedAt;

  const EosbSettlementCardData({
    required this.estimatedEosb,
    required this.confidenceScore,
    this.employerOffer,
    this.difference,
    required this.isUnderpaid,
    required this.calculatedAt,
    required super.shareCaption,
    super.referralLinkUrl,
  }) : super(type: ShareableCardType.eosbSettlement);
}

// ─── 6a. EOSB Truth Certificate Card ─────────────────────

class EosbTruthCertificateCardData extends ShareableCardData {
  final EosbCertificatePresentation presentation;

  const EosbTruthCertificateCardData({
    required this.presentation,
    required super.shareCaption,
  }) : super(type: ShareableCardType.eosbTruthCertificate);

  /// Verification QR when presentation is registered online.
  @override
  String? get referralLinkUrl =>
      presentation.showVerificationQr ? presentation.verificationUrl : null;
}

// ─── 6b. Overtime Truth Card ──────────────────────────────

class OvertimeTruthCardData extends ShareableCardData {
  final String monthLabel;
  final String companyName;
  final double totalHours;
  final double estimatedAmount;
  final double employerPaid;
  final double difference;
  final String currency;

  const OvertimeTruthCardData({
    required this.monthLabel,
    required this.companyName,
    required this.totalHours,
    required this.estimatedAmount,
    required this.employerPaid,
    required this.difference,
    this.currency = 'QAR',
    required super.shareCaption,
    super.referralLinkUrl,
  }) : super(type: ShareableCardType.overtimeTruth);
}

// ─── 6c. Friends & Family Loan Card ───────────────────────

class LoanShareEntryRow {
  const LoanShareEntryRow({
    required this.directionLabel,
    required this.amount,
    required this.dueDate,
    required this.statusLabel,
  });

  final String directionLabel;
  final double amount;
  final DateTime dueDate;
  final String statusLabel;
}

class FriendsFamilyLoanCardData extends ShareableCardData {
  final String personName;
  final double netBalance;
  final List<LoanShareEntryRow> activeEntries;

  const FriendsFamilyLoanCardData({
    required this.personName,
    required this.netBalance,
    required this.activeEntries,
    required super.shareCaption,
  }) : super(type: ShareableCardType.friendsFamilyLoan);
}

// ─── 6d. Health Insurance Compliance Card ───────────────────

class HealthInsuranceComplianceCheckRow {
  const HealthInsuranceComplianceCheckRow({
    required this.title,
    required this.statusLabel,
    required this.statusColor,
  });

  final String title;
  final String statusLabel;
  final Color statusColor;
}

class HealthInsuranceComplianceCardData extends ShareableCardData {
  final DateTime checkedAt;
  final String overviewSummary;
  final bool hasViolation;
  final List<HealthInsuranceComplianceCheckRow> checks;

  const HealthInsuranceComplianceCardData({
    required this.checkedAt,
    required this.overviewSummary,
    required this.hasViolation,
    required this.checks,
    required super.shareCaption,
  }) : super(type: ShareableCardType.healthInsuranceCompliance);
}

// ─── 6e. Health Insurance Policy Explainer Card ───────────

class HealthInsurancePolicyCardData extends ShareableCardData {
  final String documentName;
  final String summary;
  final List<String> coverageCategories;
  final List<String> exclusions;
  final List<String> networkNotes;
  final List<String> ambiguityNotes;
  final String disclaimerText;

  const HealthInsurancePolicyCardData({
    required this.documentName,
    required this.summary,
    required this.coverageCategories,
    required this.exclusions,
    required this.networkNotes,
    required this.ambiguityNotes,
    required this.disclaimerText,
    required super.shareCaption,
  }) : super(type: ShareableCardType.healthInsurancePolicy);
}

// ─── 6f. Health Insurance Claim Denial Card ───────────────

class HealthInsuranceDenialCardData extends ShareableCardData {
  final String insurerName;
  final String denialReasonLabel;
  final int stepsCompleted;
  final int stepsTotal;
  final int documentsAttached;
  final String disclaimerText;

  const HealthInsuranceDenialCardData({
    required this.insurerName,
    required this.denialReasonLabel,
    required this.stepsCompleted,
    required this.stepsTotal,
    required this.documentsAttached,
    required this.disclaimerText,
    required super.shareCaption,
  }) : super(type: ShareableCardType.healthInsuranceDenial);
}

// ─── 7. Trip Itinerary Card ───────────────────────────────

class TripItineraryCardData extends ShareableCardData {
  final String tripTitle;
  final int totalDays;
  final double totalBudget;
  final String currency;
  final String shareCode;
  final int activityCount;

  const TripItineraryCardData({
    required this.tripTitle,
    required this.totalDays,
    required this.totalBudget,
    required this.currency,
    required this.shareCode,
    required this.activityCount,
    required super.shareCaption,
  }) : super(type: ShareableCardType.tripItinerary);
}

// ─── 8. Prayer Times Card ─────────────────────────────────

class PrayerTimesCardData extends ShareableCardData {
  final String location;
  final String nextPrayer;
  final String hijriDate;

  const PrayerTimesCardData({
    required this.location,
    required this.nextPrayer,
    required this.hijriDate,
    required super.shareCaption,
  }) : super(type: ShareableCardType.prayerTimes);
}

// ─── 9. Personal Budget Card ──────────────────────────────

class PersonalBudgetSegmentRow {
  const PersonalBudgetSegmentRow({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  final String label;
  final double amount;
  final double percent;
  final Color color;
}

// ─── 10. Utility Bills Card ───────────────────────────────

class UtilityBillShareRow {
  const UtilityBillShareRow({
    required this.emoji,
    required this.provider,
    required this.amount,
    required this.dueLabel,
    required this.isOverdue,
  });

  final String emoji;
  final String provider;
  final double amount;
  final String dueLabel;
  final bool isOverdue;
}

class UtilityBillsCardData extends ShareableCardData {
  final double totalOutstanding;
  final int overdueCount;
  final int dueSoonCount;
  final int paidCount;
  final List<UtilityBillShareRow> unpaidBills;

  const UtilityBillsCardData({
    required this.totalOutstanding,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.paidCount,
    required this.unpaidBills,
    required super.shareCaption,
  }) : super(type: ShareableCardType.utilityBills);
}

class PersonalBudgetCardData extends ShareableCardData {
  final double monthlyCost;
  final double? salary;
  final double? savingsRatePercent;
  final String pressureLabel;
  final Color pressureColor;
  final List<PersonalBudgetSegmentRow> segments;
  final DateTime generatedAt;

  const PersonalBudgetCardData({
    required this.monthlyCost,
    this.salary,
    this.savingsRatePercent,
    required this.pressureLabel,
    required this.pressureColor,
    required this.segments,
    required this.generatedAt,
    required super.shareCaption,
  }) : super(type: ShareableCardType.personalBudget);
}
