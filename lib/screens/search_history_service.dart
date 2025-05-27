import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'recent_searches';

  static Future<void> addSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];

    // Aynı arama varsa öne al, yoksa ekle
    current.remove(query);
    current.insert(0, query);

    // Sadece son 4 aramayı sakla
    if (current.length > 4) {
      current.removeRange(4, current.length);
    }

    await prefs.setStringList(_key, current);
  }

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
