/// Post Engine AI usage caps and request types.
///
/// **PENDING SAYEED CONFIRMATION** — proposed limits mirror CV Maker discipline.
/// Server-side enforcement must be added in Firestore before production ship.
abstract final class PostEngineConfig {
  static const detectCategoryRequestType = 'post_engine_detect_category';
  static const extractAttributesRequestType = 'post_engine_extract_attributes';
  static const generateTitleRequestType = 'post_engine_generate_title';
  static const generateDescriptionRequestType = 'post_engine_generate_description';
  static const improveListingRequestType = 'post_engine_improve_listing';
  static const detectRiskRequestType = 'post_engine_detect_risk';
  static const extractServiceRequestRequestType =
      'post_engine_extract_service_request';

  static const haikuRequestTypes = {
    detectCategoryRequestType,
    extractAttributesRequestType,
    detectRiskRequestType,
    extractServiceRequestRequestType,
  };

  static const sonnetRequestTypes = {
    generateTitleRequestType,
    generateDescriptionRequestType,
    improveListingRequestType,
  };

  static const freeMonthlyDetectCategory = 10;
  static const freeMonthlyExtractAttributes = 10;
  static const freeMonthlyGenerateTitle = 5;
  static const freeMonthlyGenerateDescription = 5;
  static const freeMonthlyImproveListing = 5;
  static const freeMonthlyDetectRisk = 5;
  static const freeMonthlyExtractServiceRequest = 10;

  static const deterministicFeatures = {'suggestPrice', 'detectDuplicates'};
}

/// Trust backend boundary — **awaiting Sayeed approval before wiring**.
abstract final class PostTrustBoundary {
  static const proposalDoc = '''
SCAMSHIELD vs POST TRUST — PROPOSED BOUNDARY (PENDING APPROVAL):
1. ScamShield: user opens tool to scan suspicious messages/listings FROM OTHERS.
   Local-only Hive retention unchanged.
2. PostTrustEngine: automated pre-publish gate on the author's own listing draft.
   Uses server-side listing scan API (Housing pattern) + local deterministic rules.
3. No ScamShield Hive data is read/written by Post Engine.
4. ScamShield AI caps remain separate from Post Engine AI caps.
''';
}
