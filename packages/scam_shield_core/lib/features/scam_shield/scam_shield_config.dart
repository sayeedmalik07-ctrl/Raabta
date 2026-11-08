import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';

/// Scam Shield tunables — single source for caps and limits.
abstract final class ScamShieldConfig {
  static const maxInputChars = 3000;
  static const aiRequestType = 'scam_shield_classification';
  static const freeMonthlyAiLimit = 10;
  static const premiumMonthlyAiLimit = 9999;
  static const freeMonthlyWebRiskLimit = 50;
  static const premiumMonthlyWebRiskLimit = 500;
  static const webRiskRequestType = 'scam_shield_web_risk';

  /// Content types that always warrant AI contextual review.
  static const aiRequiredContentTypes = {
    ScamShieldContentType.jobOffer,
    ScamShieldContentType.rentalOffer,
    ScamShieldContentType.investmentOffer,
  };

  /// Set only after Sayeed confirms with Ooredoo / Vodafone Qatar / CRA.
  static const String? spamReportShortCode = null;
}
