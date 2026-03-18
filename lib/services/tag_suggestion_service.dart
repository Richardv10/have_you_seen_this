import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

/// Service for managing tag suggestions and history
class TagSuggestionService {
  static const String _tagsKey = 'app_tags_history';
  late SharedPreferences _prefs;
  final DatabaseService _databaseService;

  TagSuggestionService(this._databaseService);

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get all unique tags from the app (from database + history)
  Future<List<String>> getAllTags() async {
    final Set<String> allTags = {};

    // Get tags from SharedPreferences history
    final savedTags = _prefs.getStringList(_tagsKey) ?? [];
    allTags.addAll(savedTags);

    // Get tags from database
    final collections = await _databaseService.getAllCollections(limit: 1000);
    for (final collection in collections) {
      for (final item in collection.items) {
        allTags.addAll(item.tags);
      }
    }

    // Return sorted list
    return allTags.toList()..sort();
  }

  /// Get most frequently used tags
  Future<List<String>> getFrequentTags({int limit = 10}) async {
    final collections = await _databaseService.getAllCollections(limit: 1000);
    final tagCounts = <String, int>{};

    for (final collection in collections) {
      for (final item in collection.items) {
        for (final tag in item.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }

    // Sort by frequency (descending) and take top N
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(limit).map((e) => e.key).toList();
  }

  /// Get recently used tags (in reverse chronological order)
  Future<List<String>> getRecentTags({int limit = 10}) async {
    final collections = await _databaseService.getAllCollections(limit: 100);
    final seenTags = <String>{};
    final recentTags = <String>[];

    // Walk through collections (newest first) and collect unique tags
    for (final collection in collections) {
      for (final item in collection.items) {
        // Iterate tags in reverse (most recent items have most recent tags)
        for (final tag in item.tags) {
          if (!seenTags.contains(tag)) {
            seenTags.add(tag);
            recentTags.add(tag);
            if (recentTags.length >= limit) {
              return recentTags;
            }
          }
        }
      }
    }

    return recentTags;
  }

  /// Add tags to history
  Future<void> saveTags(List<String> tags) async {
    try {
      final existingTags = _prefs.getStringList(_tagsKey) ?? [];
      final uniqueTags = <String>{...existingTags, ...tags};
      await _prefs.setStringList(_tagsKey, uniqueTags.toList());
    } catch (e) {
      // ignore: avoid_print
      print('Error saving tags: $e');
    }
  }

  /// Clear tag history
  Future<void> clearHistory() async {
    try {
      await _prefs.remove(_tagsKey);
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing tag history: $e');
    }
  }

  /// Remove a specific tag from history
  Future<void> removeTag(String tag) async {
    try {
      final tags = _prefs.getStringList(_tagsKey) ?? [];
      tags.remove(tag);
      await _prefs.setStringList(_tagsKey, tags);
    } catch (e) {
      // ignore: avoid_print
      print('Error removing tag: $e');
    }
  }
}
