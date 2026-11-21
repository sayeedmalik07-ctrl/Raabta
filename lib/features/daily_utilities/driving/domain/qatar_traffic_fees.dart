/// Qatar MOI Traffic fees & penalties — verified 28 Jul 2026 against MOI/Metrash guidance.
/// Istimara tier fees flagged [needsMoiConfirmation] — confirm on portal before shipping updates.
library;

enum QatarCitizenStatus { expat, qatariCitizen }

enum VehicleCategory {
  privateCar,
  motorcycle,
  commercial,
  fleet,
}

extension VehicleCategoryX on VehicleCategory {
  String get label {
    switch (this) {
      case VehicleCategory.privateCar:
        return 'Private car';
      case VehicleCategory.motorcycle:
        return 'Motorcycle';
      case VehicleCategory.commercial:
        return 'Commercial vehicle';
      case VehicleCategory.fleet:
        return 'Fleet / company vehicles';
    }
  }
}

class LicenseRenewalEstimate {
  const LicenseRenewalEstimate({
    required this.feeQar,
    required this.validityYears,
    required this.citizenStatus,
    required this.notes,
  });

  final double feeQar;
  final int validityYears;
  final QatarCitizenStatus citizenStatus;
  final List<String> notes;
}

class IstimaraRenewalEstimate {
  const IstimaraRenewalEstimate({
    required this.category,
    required this.feeQar,
    required this.feeNeedsConfirmation,
    required this.notes,
  });

  final VehicleCategory category;
  final double? feeQar;
  final bool feeNeedsConfirmation;
  final List<String> notes;
}

abstract final class QatarTrafficFees {
  static const lastVerified = '2026-07-28';
  static const moiPortalUrl = 'https://portal.moi.gov.qa';
  static const metrashUrl = 'https://portal.moi.gov.qa/metrash';

  /// Expat primary: QAR 250 / 5 years. Citizen: QAR 500 / 10 years.
  static LicenseRenewalEstimate licenseRenewal(QatarCitizenStatus status) {
    switch (status) {
      case QatarCitizenStatus.expat:
        return const LicenseRenewalEstimate(
          feeQar: 250,
          validityYears: 5,
          citizenStatus: QatarCitizenStatus.expat,
          notes: [
            'All outstanding traffic fines must be cleared before renewal.',
            'Eye test required at an approved centre.',
            'Since Sep 2024, unpaid fines block QID, Istimara, license renewal, and exit from Qatar.',
          ],
        );
      case QatarCitizenStatus.qatariCitizen:
        return const LicenseRenewalEstimate(
          feeQar: 500,
          validityYears: 10,
          citizenStatus: QatarCitizenStatus.qatariCitizen,
          notes: [
            'All outstanding traffic fines must be cleared before renewal.',
            'Eye test required at an approved centre.',
          ],
        );
    }
  }

  /// Tier fees vary — placeholders until confirmed on MOI portal at build time.
  static IstimaraRenewalEstimate istimaraRenewal(VehicleCategory category) {
    final baseNotes = [
      'FAHES inspection required before Istimara renewal.',
      '30-day grace after expiry: renew without penalty but vehicle cannot be driven.',
      'Expired beyond 90 days may risk impoundment — confirm current MOI policy.',
      'Since Sep 2024, unpaid fines block renewal and exit from Qatar.',
    ];

    switch (category) {
      case VehicleCategory.privateCar:
        return IstimaraRenewalEstimate(
          category: category,
          feeQar: null,
          feeNeedsConfirmation: true,
          notes: [
            'Private car Istimara fee tier — confirm current amount on MOI/Metrash portal.',
            ...baseNotes,
          ],
        );
      case VehicleCategory.motorcycle:
        return IstimaraRenewalEstimate(
          category: category,
          feeQar: null,
          feeNeedsConfirmation: true,
          notes: [
            'Motorcycle Istimara fee tier — confirm on MOI portal.',
            ...baseNotes,
          ],
        );
      case VehicleCategory.commercial:
        return IstimaraRenewalEstimate(
          category: category,
          feeQar: null,
          feeNeedsConfirmation: true,
          notes: [
            'Commercial vehicle fees differ — confirm category on MOI portal.',
            ...baseNotes,
          ],
        );
      case VehicleCategory.fleet:
        return IstimaraRenewalEstimate(
          category: category,
          feeQar: null,
          feeNeedsConfirmation: true,
          notes: [
            'Fleet/company registration fees vary — confirm with MOI Traffic.',
            ...baseNotes,
          ],
        );
    }
  }

  static const expiredIstimaraPenalty =
      'Fine range QAR 1,500–3,000 plus 2 black points (after grace period).';

  static const unregisteredVehiclePenalty =
      'Driving without valid Istimara: QAR 3,000 fine plus 2 black points.';

  static const blackPointsLadder = [
    'First threshold breach (12 points): licence suspended 3 months.',
    'Second breach: suspension 6 months.',
    'Fifth repeat breach at 6 points: permanent cancellation — fresh driving test after one year.',
  ];

  static const unpaidFinesBlockWarning =
      'Since September 2024, MOI blocks exit from Qatar (air, land, sea) for unpaid traffic fines. '
      'Unpaid fines also block QID renewal, Istimara renewal, and driving licence renewal.';
}
