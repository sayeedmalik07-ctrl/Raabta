import 'package:shared_preferences/shared_preferences.dart';

abstract final class PhraseFavoritesService {
  static const _key = 'arabic_phrase_favorites_v1';

  static Future<Set<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      return raw.toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> toggle(String phraseId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await load();
    if (set.contains(phraseId)) {
      set.remove(phraseId);
    } else {
      set.add(phraseId);
    }
    await prefs.setStringList(_key, set.toList());
  }

  static Future<bool> isFavorite(String phraseId) async {
    final set = await load();
    return set.contains(phraseId);
  }
}
