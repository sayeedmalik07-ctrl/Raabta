import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

enum PostRuleId {
  requiredField,
  minLength,
  minPhotos,
  minPrice,
  phoneFormat,
  categoryCompliance,
  duplicateListing,
  suspiciousPricing,
}

class PostRule {
  const PostRule({
    required this.id,
    required this.messageKey,
    this.params = const {},
  });

  final PostRuleId id;
  final String messageKey;
  final Map<String, String> params;
}

abstract final class GlobalPostRules {
  static List<PostRuleId> baseline() => const [
        PostRuleId.requiredField,
        PostRuleId.minPhotos,
        PostRuleId.duplicateListing,
        PostRuleId.suspiciousPricing,
      ];
}

abstract final class MarketplaceRules {
  static List<PostRuleId> forCategory(String categoryPath) {
    final rules = <PostRuleId>[...GlobalPostRules.baseline()];
    if (categoryPath.contains('vehicle') || categoryPath.contains('car')) {
      rules.add(PostRuleId.categoryCompliance);
    }
    return rules;
  }
}

abstract final class HousingRules {
  static List<PostRuleId> rules() => const [
        PostRuleId.requiredField,
        PostRuleId.minPhotos,
        PostRuleId.duplicateListing,
        PostRuleId.suspiciousPricing,
        PostRuleId.phoneFormat,
      ];
}

abstract final class JobRules {
  static List<PostRuleId> rules() => const [
        PostRuleId.requiredField,
        PostRuleId.minLength,
      ];
}

abstract final class BusinessRules {
  static List<PostRuleId> rules() => GlobalPostRules.baseline();
}

abstract final class ServiceRules {
  static List<PostRuleId> rules() => GlobalPostRules.baseline();
}

class PostRulesComposer {
  const PostRulesComposer();

  List<PostRuleId> compose({
    required PostVertical vertical,
    required String categoryPath,
  }) {
    return switch (vertical) {
      PostVertical.marketplace => MarketplaceRules.forCategory(categoryPath),
      PostVertical.housing => HousingRules.rules(),
      PostVertical.jobs => JobRules.rules(),
      PostVertical.business => BusinessRules.rules(),
      PostVertical.services => ServiceRules.rules(),
    };
  }
}
