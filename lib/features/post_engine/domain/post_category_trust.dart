import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';

/// Config-driven verification requirements for a service category (Part 11C).
class PostCategoryTrustRequirements {
  const PostCategoryTrustRequirements({
    this.identityVerificationRequired = false,
    this.businessVerificationRequired = false,
    this.licenseVerificationRequired = false,
  });

  final bool identityVerificationRequired;
  final bool businessVerificationRequired;
  final bool licenseVerificationRequired;

  bool get hasAnyRequirement =>
      identityVerificationRequired ||
      businessVerificationRequired ||
      licenseVerificationRequired;

  bool get hasStubRequirement =>
      businessVerificationRequired || licenseVerificationRequired;

  static PostCategoryTrustRequirements forPath(
    PostVerticalSchema schema,
    String categoryPath,
  ) {
    final node = schema.findCategoryByPath(categoryPath);
    if (node == null) return const PostCategoryTrustRequirements();
    return PostCategoryTrustRequirements(
      identityVerificationRequired: node.identityVerificationRequired,
      businessVerificationRequired: node.businessVerificationRequired,
      licenseVerificationRequired: node.licenseVerificationRequired,
    );
  }
}
