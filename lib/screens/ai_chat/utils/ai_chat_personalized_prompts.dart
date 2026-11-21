import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Builds up to 3 profile-aware starter prompts for the empty state.
abstract final class AiChatPersonalizedPrompts {
  static List<String> build(UserAIProfile? profile, String locale) {
    if (profile == null) return const [];

    final prompts = <String>[];

    final profession = profile.profession.trim();
    if (profession.isNotEmpty &&
        profession.toLowerCase() != 'unknown' &&
        profession.toLowerCase() != 'not set') {
      prompts.add(
        AiChatStrings.t('ai_personal_profession', locale).replaceAll(
          '{profession}',
          profession,
        ),
      );
    }

    final area = profile.preferredArea.trim();
    if (area.isNotEmpty &&
        area.toLowerCase() != 'unknown' &&
        prompts.length < 3) {
      prompts.add(
        AiChatStrings.t('ai_personal_area', locale).replaceAll('{area}', area),
      );
    }

    final weakest = _weakestCategory(profile.score);
    if (weakest != null && prompts.length < 3) {
      prompts.add(
        AiChatStrings.t('ai_personal_score_$weakest', locale),
      );
    }

    if (profile.nationality.trim().isNotEmpty &&
        profile.nationality.toLowerCase() != 'unknown' &&
        prompts.length < 3) {
      prompts.add(
        AiChatStrings.t('ai_personal_nationality', locale).replaceAll(
          '{nationality}',
          profile.nationality,
        ),
      );
    }

    return prompts.take(3).toList();
  }

  static String? _weakestCategory(ExpatLifeScore score) {
    final entries = <MapEntry<String, double>>[
      MapEntry('documentation', score.documentation),
      MapEntry('career', score.career),
      MapEntry('housing', score.housing),
      MapEntry('financial', score.financial),
      MapEntry('health', score.health),
      MapEntry('community', score.community),
    ];
    entries.sort((a, b) => a.value.compareTo(b.value));
    final weakest = entries.first;
    if (weakest.value >= 12) return null;
    return weakest.key;
  }
}
