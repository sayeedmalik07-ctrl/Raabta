import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';

/// Canonical status colors for Truth Engine result surfaces.
abstract final class TruthEngineStatusColors {
  static const critical = AppColors.errorBright;
  static const warning = AppColors.accentGold;
  static const needsVerification = AppColors.cyanGlow;
  static const compliant = AppColors.successBright;
  static final informational = AppColors.textSecondary;

  static Color forHealthCompliance(HealthComplianceStatus status) {
    return switch (status) {
      HealthComplianceStatus.compliant => compliant,
      HealthComplianceStatus.violation => critical,
      HealthComplianceStatus.needsVerification => needsVerification,
      HealthComplianceStatus.informational ||
      HealthComplianceStatus.notApplicable =>
        informational,
    };
  }

  static Color forTenancyCompliance(TenancyComplianceStatus status) {
    return switch (status) {
      TenancyComplianceStatus.compliant => compliant,
      TenancyComplianceStatus.violation => warning,
      TenancyComplianceStatus.critical => critical,
      TenancyComplianceStatus.needsVerification => needsVerification,
      TenancyComplianceStatus.informational => informational,
    };
  }

  static Color forTransferReadiness(TransferReadinessStatus status) {
    return switch (status) {
      TransferReadinessStatus.compliant => compliant,
      TransferReadinessStatus.warning => warning,
      TransferReadinessStatus.critical => critical,
      TransferReadinessStatus.needsVerification => needsVerification,
      TransferReadinessStatus.informational => informational,
    };
  }

  static Color engineAccent(TruthEngineFamily engine) {
    return switch (engine) {
      TruthEngineFamily.eosb => AppColors.chipEosb,
      TruthEngineFamily.healthInsurance => AppColors.chipHealthInsurance,
      TruthEngineFamily.tenancy => AppColors.chipLease,
      TruthEngineFamily.sponsorshipTransfer => AppColors.chipSponsorshipTransfer,
    };
  }
}

enum TruthEngineFamily {
  eosb,
  healthInsurance,
  tenancy,
  sponsorshipTransfer,
}
