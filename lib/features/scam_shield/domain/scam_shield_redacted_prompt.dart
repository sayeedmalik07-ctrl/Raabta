import 'package:flutter/foundation.dart';

/// Full Claude prompt that must only contain redacted ScamShield content.
final class ScamShieldRedactedPrompt {
  const ScamShieldRedactedPrompt._(this.value);

  final String value;

  static ScamShieldRedactedPrompt fromBuild(String prompt) {
    return ScamShieldRedactedPrompt._(prompt);
  }

  @visibleForTesting
  factory ScamShieldRedactedPrompt.testing(String prompt) {
    return ScamShieldRedactedPrompt._(prompt);
  }
}
