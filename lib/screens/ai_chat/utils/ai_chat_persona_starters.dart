import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';
import 'package:raabta/features/home/utils/home_ai_chip_hint_order.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';

/// Persona-ordered conversation starters for the chat empty state (Part B ordering).
abstract final class AiChatPersonaStarters {
  static const maxStarters = 3;

  static List<String> prompts({
    required KnowQatarPersona persona,
    required String locale,
  }) {
    final ordered = HomeAiChipHintOrder.forPersona(persona);
    final localized = <String>[];
    for (final key in ordered) {
      if (localized.length >= maxStarters) break;
      final text = HomeFloatingAiStrings.t(key, locale).trim();
      if (text.isEmpty || text == key) continue;
      localized.add(text);
    }
    if (localized.isNotEmpty) return localized;
    return _genericFallback(locale);
  }

  static List<String> _genericFallback(String locale) {
    return HomeAiChipHintOrder.forPersona(KnowQatarPersona.visitor)
        .take(maxStarters)
        .map((key) => HomeFloatingAiStrings.t(key, locale))
        .where((text) => text.trim().isNotEmpty)
        .toList();
  }
}
