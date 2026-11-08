import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_id_generator.dart';

/// Public verification URLs for Phase 2 registered certificates.
abstract final class EosbCertificateVerificationUrls {
  static String publicVerifyUrl(String certificateIdStorage) {
    final encoded = Uri.encodeComponent(certificateIdStorage);
    return '${AppConfig.publicWebsiteUrl}/verify/eosb/$encoded';
  }

  static String apiVerifyUrl(String certificateIdStorage) {
    final encoded = Uri.encodeComponent(certificateIdStorage);
    return '${AppConfig.backendUrl}/api/eosb/certificates/$encoded';
  }

  static String appDeepLink(String certificateIdStorage) {
    return 'raabta://eosb/verify/${Uri.encodeComponent(certificateIdStorage)}';
  }

  static bool isValidCertificateId(String id) {
    return EosbCertificateIdGenerator.isValidStorageId(id);
  }
}
