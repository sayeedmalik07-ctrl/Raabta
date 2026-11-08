/// Static close-out signposts for Leaving Qatar (Part A) — offline catalog only.
abstract final class LeavingQatarCloseoutConfig {
  static const lastVerifiedIso = '2026-10-16';

  /// QNA reporting MOI vehicle exit-permit rules (22 May 2024).
  static const qnaVehicleExitPermitSourceDate = '2024-05-22';

  static const metrashPortalUrl =
      'https://portal.moi.gov.qa/metrash';

  static const moiTrafficServicesUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/services/inquiries/trafficservices';

  static const moiTrafficCertificatesUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/services/inquiries/trafficservices/certificate';

  static const qnaVehicleExitPermitUrl =
      'https://qna.org.qa/en/news/news-details?id=0050-ministry-of-interior-announces-rules,-procedures-for-vehicle-exit-permits-to-leave-the-country&date=22/05/2024';

  static const moeheEduservicesUrl = 'https://eduservices.edu.gov.qa/';

  static const moeheIssuanceInfoUrl =
      'https://www.edu.gov.qa/en/Content/Issuanceofschoolcertificate';

  static const municipalityPublicServicesUrl =
      'https://publicservices.mm.gov.qa/index.aspx';

  static const moiPccDepartmentUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/departmentcommittees/evidencesinformation/evidencesinformationEN';

  static const moiConductCertificateUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/infocenter/conductcertificate/';

  static const moiPortalUrl = 'https://portal.moi.gov.qa';

  static const tenancyRoute = '/tenancy';
  static const marketplaceRoute = '/marketplace';

  /// Local-only checklist item ids (SharedPreferences).
  static const itemIds = <String>[
    'vehicle_ownership',
    'traffic_violations',
    'vehicle_export_signpost',
    'school_records',
    'pets_planning',
    'police_clearance',
    'traffic_certificates',
    'tenancy_notice',
    'marketplace_belongings',
    'qdi_airport',
  ];

  static const forbiddenCopySubstrings = [
    'no-claims',
    'no claims',
    'withdrawal certificate',
    'blocks rp cancellation',
    'block rp cancellation',
    'blocks residence',
    'registration blocks',
  ];
}
