import 'package:flutter/material.dart';

/// Doc-type iconography and deep-link routes for scanner insights.
abstract final class ScannerDocTypeUi {
  static IconData iconFor(String? docType) {
    switch (docType) {
      case 'qid':
        return Icons.badge_outlined;
      case 'passport':
        return Icons.menu_book_outlined;
      case 'visa':
        return Icons.flight_takeoff;
      case 'labourCard':
        return Icons.work_outline;
      case 'drivingLicense':
        return Icons.directions_car_outlined;
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'bill':
        return Icons.request_quote_outlined;
      case 'labReport':
        return Icons.biotech_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      case 'medicalCertificate':
        return Icons.health_and_safety_outlined;
      case 'vaccinationRecord':
        return Icons.vaccines_outlined;
      case 'healthInsurance':
      case 'healthInsuranceClaim':
        return Icons.local_hospital_outlined;
      case 'imagingReport':
        return Icons.monitor_heart_outlined;
      case 'bookingConfirmation':
        return Icons.airplane_ticket_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  /// Feature hub route related to this document type, if any.
  static String? featureRouteFor(String? docType) {
    switch (docType) {
      case 'qid':
      case 'passport':
      case 'visa':
      case 'labourCard':
      case 'drivingLicense':
        return '/visa';
      case 'healthInsurance':
      case 'healthInsuranceClaim':
      case 'labReport':
      case 'prescription':
      case 'medicalCertificate':
      case 'vaccinationRecord':
      case 'imagingReport':
        return '/health-insurance';
      default:
        return null;
    }
  }

  static String featureActionKeyFor(String? docType) {
    final route = featureRouteFor(docType);
    if (route == '/visa') return 'ai_open_visa';
    if (route == '/health-insurance') return 'ai_open_health';
    return 'ai_view_vault';
  }
}
