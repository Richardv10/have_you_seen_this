import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// StateNotifier for managing all content collections
class CollectionsNotifier extends ChangeNotifier {
  final StorageService _storageService;
  List<DailyCollection> _collections = [];
  DailyCollection? _todayCollection;
  bool _isLoading = false;

  CollectionsNotifier(this._storageService);

  // Getters
  List<DailyCollection> get collections => _collections;
  DailyCollection? get todayCollection => _todayCollection;
  bool get isLoading => _isLoading;

  /// Initialize and load all collections
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _collections = await _storageService.getAllCollections();
      _todayCollection = await _storageService.getTodaysCollection();
    } catch (e) {
      print('Error initializing collections: $e');
    }

    _isLoading = false;
    notifyListeners();
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
    await _storageService.saveCollection(_todayCollection!);

    notifyListeners();
  }

  /// Remove content from a collection
  Future<void> removeContent(DateTime date, String contentId) async {
    await _storageService.removeContent(date, contentId);

    if (_todayCollection?.isToday == true) {
      _todayCollection = await _storageService.getTodaysCollection();
    }

    _collections = await _storageService.getAllCollections();
    notifyListeners();
  }

  /// Delete an entire collection
  Future<void> deleteCollection(DateTime date) async {
    await _storageService.deleteCollection(date);

    if (_todayCollection?.date == date) {
      _todayCollection = await _storageService.getTodaysCollection();
    }

    _collections = await _storageService.getAllCollections();
    notifyListeners();
  }

  /// Refresh all data from storage
  Future<void> refresh() async {
    _collections = await _storageService.getAllCollections();
    _todayCollection = await _storageService.getTodaysCollection();
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
}
