import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';

/// StateNotifier for managing all content collections
class CollectionsNotifier extends ChangeNotifier {
  final DatabaseService _databaseService;
  List<DailyCollection> _collections = [];
  DailyCollection? _todayCollection;
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _pageSize = 30; // Load 30 days at a time

  CollectionsNotifier(this._databaseService);

  // Getters
  List<DailyCollection> get collections => _collections;
  DailyCollection? get todayCollection => _todayCollection;
  bool get isLoading => _isLoading;

  /// Initialize and load collections
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _collections = await _databaseService.getAllCollections(
        offset: _currentOffset,
        limit: _pageSize,
      );
      _todayCollection = await _databaseService.getTodaysCollection();
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing collections: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more collections (pagination)
  Future<void> loadMore() async {
    try {
      _currentOffset += _pageSize;
      final more = await _databaseService.getAllCollections(
        offset: _currentOffset,
        limit: _pageSize,
      );
      _collections.addAll(more);
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading more collections: $e');
    }
  }

  /// Add new content to today's collection
  Future<void> addContentToday(
    ContentType type, {
    String? title,
    String? description,
    String? source,
    String? contentData,
    String? mimeType,
  }) async {
    const uuid = Uuid();
    final content = SharedContent(
      id: uuid.v4(),
      contentType: type,
      title: title,
      description: description,
      timestamp: DateTime.now(),
      source: source,
      contentData: contentData,
      mimeType: mimeType,
    );

    _todayCollection ??= DailyCollection(
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );
    _todayCollection!.addContent(content);
    await _databaseService.saveCollection(_todayCollection!);

    notifyListeners();
  }

  /// Remove content from a collection
  Future<void> removeContent(DateTime date, String contentId) async {
    await _databaseService.removeContent(date, contentId);

    if (_todayCollection?.isToday == true) {
      _todayCollection = await _databaseService.getTodaysCollection();
    }

    _collections = await _databaseService.getAllCollections(
      offset: 0,
      limit: _pageSize,
    );
    _currentOffset = 0;
    notifyListeners();
  }

  /// Delete an entire collection
  Future<void> deleteCollection(DateTime date) async {
    await _databaseService.deleteCollection(date);

    if (_todayCollection?.date == date) {
      _todayCollection = await _databaseService.getTodaysCollection();
    }

    _collections = await _databaseService.getAllCollections(
      offset: 0,
      limit: _pageSize,
    );
    _currentOffset = 0;
    notifyListeners();
  }

  /// Delete collections older than the specified duration
  Future<int> deleteOlderThan(Duration duration) async {
    final deleted = await _databaseService.deleteOlderThan(duration);
    await refresh();
    return deleted;
  }

  /// Refresh all data from storage
  Future<void> refresh() async {
    _collections = await _databaseService.getAllCollections(
      offset: 0,
      limit: _pageSize,
    );
    _currentOffset = 0;
    _todayCollection = await _databaseService.getTodaysCollection();
    notifyListeners();
  }

  /// Get total items count
  int getTotalItemsCount() {
    int total = 0;
    for (final collection in _collections) {
      total += collection.count;
    }
    return total;
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getStats() async {
    return await _databaseService.getStats();
  }

  /// Update tags for a content item
  Future<void> updateContentTags(String contentId, List<String> tags) async {
    try {
      // Find the content item and update it
      for (final collection in _collections) {
        final itemIndex = collection.items.indexWhere((item) => item.id == contentId);
        if (itemIndex != -1) {
          // Update in database
          await _databaseService.updateContentTags(
            collection.date,
            contentId,
            tags,
          );
          // Update in memory
          collection.items[itemIndex] = collection.items[itemIndex].copyWith(tags: tags);
          break;
        }
      }

      // Also check today's collection
      if (_todayCollection != null) {
        final itemIndex = _todayCollection!.items.indexWhere((item) => item.id == contentId);
        if (itemIndex != -1) {
          await _databaseService.updateContentTags(
            _todayCollection!.date,
            contentId,
            tags,
          );
          _todayCollection!.items[itemIndex] = _todayCollection!.items[itemIndex].copyWith(tags: tags);
        }
      }

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error updating tags: $e');
    }
  }
}

