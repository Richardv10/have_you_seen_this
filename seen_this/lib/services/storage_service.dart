import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for managing local storage of daily collections
class StorageService {
  static const String _collectionsKey = 'daily_collections';
  late SharedPreferences _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get today's collection (creates if doesn't exist)
  Future<DailyCollection> getTodaysCollection() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getCollectionByDate(today);
  }

  /// Get a collection for a specific date
  Future<DailyCollection> getCollectionByDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final allCollections = await getAllCollections();

    try {
      return allCollections.firstWhere(
        (collection) =>
            collection.date.year == normalizedDate.year &&
            collection.date.month == normalizedDate.month &&
            collection.date.day == normalizedDate.day,
      );
    } catch (e) {
      // Collection doesn't exist, create a new one
      return DailyCollection(date: normalizedDate);
    }
  }

  /// Get all collections sorted by date (newest first)
  Future<List<DailyCollection>> getAllCollections() async {
    final jsonString = _prefs.getString(_collectionsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final collections =
          jsonList
              .map((json) => DailyCollection.fromJson(json as Map<String, dynamic>))
              .toList();

      // Sort by date, newest first
      collections.sort((a, b) => b.date.compareTo(a.date));
      return collections;
    } catch (e) {
      print('Error parsing collections: $e');
      return [];
    }
  }

  /// Save a collection
  Future<void> saveCollection(DailyCollection collection) async {
    final allCollections = await getAllCollections();

    // Remove existing collection with same date
    allCollections.removeWhere(
      (c) =>
          c.date.year == collection.date.year &&
          c.date.month == collection.date.month &&
          c.date.day == collection.date.day,
    );

    // Add the updated collection
    allCollections.add(collection);

    // Save back to storage
    final jsonList = allCollections.map((c) => c.toJson()).toList();
    await _prefs.setString(_collectionsKey, jsonEncode(jsonList));
  }

  /// Add content to today's collection
  Future<void> addToTodaysCollection(SharedContent content) async {
    final today = await getTodaysCollection();
    today.addContent(content);
    await saveCollection(today);
  }

  /// Remove content from a collection
  Future<void> removeContent(DateTime date, String contentId) async {
    final collection = await getCollectionByDate(date);
    collection.removeContent(contentId);
    await saveCollection(collection);
  }

  /// Delete an entire collection
  Future<void> deleteCollection(DateTime date) async {
    final allCollections = await getAllCollections();
    allCollections.removeWhere(
      (c) =>
          c.date.year == date.year &&
          c.date.month == date.month &&
          c.date.day == date.day,
    );

    final jsonList = allCollections.map((c) => c.toJson()).toList();
    await _prefs.setString(_collectionsKey, jsonEncode(jsonList));
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _prefs.remove(_collectionsKey);
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    final collections = await getAllCollections();
    int totalItems = 0;
    for (final collection in collections) {
      totalItems += collection.count;
    }

    return {
      'totalCollections': collections.length,
      'totalItems': totalItems,
      'oldestDate': collections.isNotEmpty ? collections.last.date : null,
      'newestDate': collections.isNotEmpty ? collections.first.date : null,
    };
  }
}
