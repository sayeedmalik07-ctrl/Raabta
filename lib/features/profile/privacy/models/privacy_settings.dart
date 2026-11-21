/// User privacy preferences stored on `users/{uid}`.
class PrivacySettings {
  const PrivacySettings({
    required this.aiPersonalizationEnabled,
    required this.profileVisibilityPublic,
    required this.allowContactFromOthers,
    required this.sensitiveAiDisclaimerAcknowledged,
  });

  final bool aiPersonalizationEnabled;
  final bool profileVisibilityPublic;
  final bool allowContactFromOthers;
  final bool sensitiveAiDisclaimerAcknowledged;

  static const defaults = PrivacySettings(
    aiPersonalizationEnabled: true,
    profileVisibilityPublic: true,
    allowContactFromOthers: true,
    sensitiveAiDisclaimerAcknowledged: false,
  );

  PrivacySettings copyWith({
    bool? aiPersonalizationEnabled,
    bool? profileVisibilityPublic,
    bool? allowContactFromOthers,
    bool? sensitiveAiDisclaimerAcknowledged,
  }) {
    return PrivacySettings(
      aiPersonalizationEnabled:
          aiPersonalizationEnabled ?? this.aiPersonalizationEnabled,
      profileVisibilityPublic:
          profileVisibilityPublic ?? this.profileVisibilityPublic,
      allowContactFromOthers:
          allowContactFromOthers ?? this.allowContactFromOthers,
      sensitiveAiDisclaimerAcknowledged: sensitiveAiDisclaimerAcknowledged ??
          this.sensitiveAiDisclaimerAcknowledged,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'aiPersonalizationEnabled': aiPersonalizationEnabled,
        'profileVisibilityPublic': profileVisibilityPublic,
        'allowContactFromOthers': allowContactFromOthers,
        'sensitiveAiDisclaimerAcknowledged': sensitiveAiDisclaimerAcknowledged,
      };

  factory PrivacySettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return defaults;
    return PrivacySettings(
      aiPersonalizationEnabled:
          data['aiPersonalizationEnabled'] as bool? ?? true,
      profileVisibilityPublic: data['profileVisibilityPublic'] as bool? ?? true,
      allowContactFromOthers: data['allowContactFromOthers'] as bool? ?? true,
      sensitiveAiDisclaimerAcknowledged:
          data['sensitiveAiDisclaimerAcknowledged'] as bool? ?? false,
    );
  }
}
