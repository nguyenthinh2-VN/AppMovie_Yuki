import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/watch_history_item.dart';

class WatchHistoryLocalDataSource {
  static const String _storageKey = 'yuki_watch_history_list';

  Future<List<WatchHistoryItem>> getHistoryList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_storageKey) ?? [];
      final items = listJson
          .map((jsonStr) {
            try {
              return WatchHistoryItem.fromJson(jsonStr);
            } catch (_) {
              return null;
            }
          })
          .whereType<WatchHistoryItem>()
          .toList();

      // Sort by latest updated first
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItem(WatchHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getHistoryList();

      // Remove existing item with same slug if present
      final updatedList = currentList.where((e) => e.movieSlug != item.movieSlug).toList();

      // Insert new/updated item at the beginning
      updatedList.insert(0, item);

      // Keep max 50 recent items
      final trimmed = updatedList.take(50).toList();
      final listJson = trimmed.map((e) => e.toJson()).toList();

      await prefs.setStringList(_storageKey, listJson);
    } catch (_) {}
  }

  Future<WatchHistoryItem?> getItem(String movieSlug) async {
    final list = await getHistoryList();
    try {
      return list.firstWhere((e) => e.movieSlug == movieSlug);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteItem(String movieSlug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getHistoryList();
      final updatedList = currentList.where((e) => e.movieSlug != movieSlug).toList();
      final listJson = updatedList.map((e) => e.toJson()).toList();
      await prefs.setStringList(_storageKey, listJson);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
