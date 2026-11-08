import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Explicit allowlisted profile fields for Global Search Ask AI (S9).
abstract final class SearchAskAiProfilePayload {
  static Map<String, dynamic> build(UserAIProfile? profile) {
    if (profile == null) return const {};

    return {
      if (profile.profession.trim().isNotEmpty) 'profession': profile.profession,
      if (profile.nationality.trim().isNotEmpty)
        'nationality': profile.nationality,
      if (profile.preferredArea.trim().isNotEmpty)
        'preferredArea': profile.preferredArea,
      if (profile.language.trim().isNotEmpty) 'language': profile.language,
      if (profile.yearsExperience > 0)
        'yearsExperience': profile.yearsExperience,
    };
  }
}
