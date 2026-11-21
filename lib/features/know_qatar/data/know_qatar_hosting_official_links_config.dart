/// Official outbound links for Know Qatar — Hosting Visitors moment only.
abstract final class KnowQatarHostingOfficialLinksConfig {
  /// MOI family visit service detail (Phase 0 audited URL — do not shorten).
  static const moiFamilyVisitServiceUrl =
      'https://portal.moi.gov.qa/wps/portal/!ut/p/z0/fY6xCsJAEER_xcYy3BnEkDKWGrWTeI2syUZWc3txb4n69x5i7VQzMDyecaYxjmGiKygFhiHtk1ud96WtFuXBbm2Rr21VLus6P25yuyvMxrj_h0Sg2-PhKuPawIovNc2z9QNdMkpTGDUDmdsIWYcjiHpkbYP3pIo4t1dkFBig88QUVb5moeefIen7EqRDicAdvkZQIVCEvgeSmLAoE7WYGgfOnkHus4kiaQKnmPHuTh_zt0dh/';

  /// MOI English news — residency vs visit rules (published 5 December 2023).
  static const moiFamilyPolicyNewsEnUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/mediacenter/moinews/newsdetails/!ut/p/z1/tVRdd6IwEP01PuZkJAjhkWIrfmvBL156AgltduWjMVvrv99Uu-2pe9T2dJcXApncuTczc3GClzgp2ZO8Z1pWJVub71Xi3HV9aodNaPY7FnXB77Z8L7oNCMwBLz4G0BAo-FHci6_GgQXQxMn583Oc4KTOJMcr7rmU57mLvJwRZHPiIUZJjrKUZARsm2ct6yU6K3WtH_BqmxVrmSJZaqFKoRFTDdgwVFSyFNtNAz6Fd-APJx4fLvE_nB954De9MfTHgXdtln4_HocTaxq2Pnf-TEBynt5R_g6FK7O8IaPhJG4O55_gn-xDemG7CyQyCAOHmAoOhoEVTAFo6zXgXIkvkTyfwnZfA86oiJi6m_p4ZdS6J2_ba-LovZ3S3PEEAQfxLEuRbdoBUS5cZDmCg2e3XCdlePEkxRbPykoVptsvwLv_FX5iHeAXwfBuOru-NdFc1DoSa5FpYTKajYHp9-6ffo8emBK8AfFyhNqiZkoXotSm8QM__vgjEkxlDzfVel1tZ_X71rfU9D7W7O_ON94hfzw-Jr4Z2cqQftZ4eWJm-RulrCoKqbUQDbgXpVBszXghS7nRau9JVV6-epPUu7RSXKgNK7l4rplWkmnB8pxJZURv9qLzvehf9XsGYwzmWl8sAodwXBOIRzb4zk27P7AiAoF1JDr6ol0d4E_MXwda_wT-jT2ddEwNnLlLqGcmswPfhO9dco8vlPhrtlwXs4KSnZQS_by9zttxHhYFmoyGIrXpjmy3cV4EKX15LX4DK7w15A!!/dz/d5/L0lHSkovd0RNQUVrQUVnQSEhLzROVkUvZW5fVVM!/';

  static const mophQhisVisitorPortalUrl =
      'https://qhis.moph.gov.qa/insurance-plans?tabName=visitor';

  static const moiPolicyAnnouncementDateIso = '2023-12-05';

  /// Date MOI URLs were reachable in implementation QA (not MoPH product verification).
  static const moiUrlLastVerifiedIso = '2026-10-16';

  static const linkMoiFamilyVisit = 'moi_family_visit';
  static const linkMoiPolicy2023 = 'moi_policy_2023';
  static const linkMophQhisVisitor = 'moph_qhis_visitor';

  static String? urlForLinkId(String linkId) {
    switch (linkId) {
      case linkMoiFamilyVisit:
        return moiFamilyVisitServiceUrl;
      case linkMoiPolicy2023:
        return moiFamilyPolicyNewsEnUrl;
      case linkMophQhisVisitor:
        return mophQhisVisitorPortalUrl;
      default:
        return null;
    }
  }

  static String? urlVerifiedIsoForLinkId(String linkId) {
    switch (linkId) {
      case linkMoiFamilyVisit:
      case linkMoiPolicy2023:
        return moiUrlLastVerifiedIso;
      case linkMophQhisVisitor:
        return null;
      default:
        return null;
    }
  }

  static String titleKeyForLinkId(String linkId) {
    switch (linkId) {
      case linkMoiFamilyVisit:
        return 'kq_hosting_link_moi_service_title';
      case linkMoiPolicy2023:
        return 'kq_hosting_link_moi_policy_title';
      case linkMophQhisVisitor:
        return 'kq_hosting_link_moph_qhis_title';
      default:
        return linkId;
    }
  }

  static String summaryKeyForLinkId(String linkId) {
    switch (linkId) {
      case linkMoiFamilyVisit:
        return 'kq_hosting_link_moi_service_summary';
      case linkMoiPolicy2023:
        return 'kq_hosting_link_moi_policy_summary';
      case linkMophQhisVisitor:
        return 'kq_hosting_link_moph_qhis_summary';
      default:
        return linkId;
    }
  }

  static String sourceNameKeyForLinkId(String linkId) {
    switch (linkId) {
      case linkMoiFamilyVisit:
      case linkMoiPolicy2023:
        return 'kq_source_moi';
      case linkMophQhisVisitor:
        return 'kq_source_moph';
      default:
        return 'kq_source_moi';
    }
  }

  /// Copy guard for unit tests.
  static const forbiddenCopySubstrings = <String>[
    '10,000',
    '10000',
    '6,000',
    '6000',
    '200 per day',
    '200/day',
    'guaranteed approval',
    'will be approved',
    'family_visa',
    'alerts_safety',
  ];
}
