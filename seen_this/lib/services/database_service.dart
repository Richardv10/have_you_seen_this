import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for managing SQLite database operations
class DatabaseService {
  static const String _dbName = 'seen_this.db';
  static const int _dbVersion = 1;

  late Database _db;

  /// Initialize the database
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );

    // Migrate data from SharedPreferences if it exists
    await _migrateFromSharedPreferences();
  }

  /// Create all necessary tables
  Future<void> _createTables(Database db, int version) async {
    // Collections table
    await db.execute('''
      CREATE TABLE collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Content items table
    await db.execute('''
      CREATE TABLE content_items (
        id TEXT PRIMARY KEY,
        collection_date TEXT NOT NULL,
        content_type TEXT NOT NULL,
        title TEXT,
        description TEXT,
        timestamp TEXT NOT NULL,
        source TEXT,
        content_data TEXT,
        mime_type TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (collection_date) REFERENCES collections(date) ON DELETE CASCADE
      )
    ''');

    // Indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_content_collection_date ON content_items(collection_date)',
    );
    await db.execute(
      'CREATE INDEX idx_content_timestamp ON content_items(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_collection_date ON collections(date)',
    );
  }

  /// Handle database upgrades
  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle migrations here in future versions
  }

  /// Migrate existing data from SharedPreferences to SQLite
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const collectionsKey = 'daily_collections';
      final jsonString = prefs.getString(collectionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return; // No data to migrate
      }

      // Check if migration already done
      final existing = await _db.query('collections', limit: 1);
      if (existing.isNotEmpty) {
        return; // Already migrated
      }

      // Parse old data
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (final json in jsonList) {
        final collection = DailyCollection.fromJson(json as Map<String, dynamic>);
        await saveCollection(collection);
      }

      // Clear old data after successful migration
      await prefs.remove(collectionsKey);
      // ignore: avoid_print
      print('Successfully migrated data from SharedPreferences to SQLite');
    } catch (e) {
      // ignore: avoid_print
      print('Migration error: $e');
    }
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
    final dateString = normalizedDate.toIso8601String().split('T')[0];

    try {
      final collectionRow = await _db.query(
        'collections',
        where: 'date = ?',
        whereArgs: [dateString],
      );

      if (collectionRow.isEmpty) {
        return DailyCollection(date: normalizedDate);
      }

      final itemRows = await _db.query(
        'content_items',
        where: 'collection_date = ?',
        whereArgs: [dateString],
        orderBy: 'timestamp DESC',
      );

      final items = itemRows
          .map((row) {
            final json = Map<String, dynamic>.from(row);
            // Fix the content_type field for fromJson compatibility
            json['contentType'] = json['content_type'];
            json.remove('content_type');
            return SharedContent.fromJson(json);
          })
          .toList();

      return DailyCollection(
        date: normalizedDate,
        items: items,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error getting collection: $e');
      return DailyCollection(date: normalizedDate);
    }
  }

  /// Get all collections sorted by date (newest first)
  /// Supports pagination
  Future<List<DailyCollection>> getAllCollections({
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      final collectionRows = await _db.query(
        'collections',
        orderBy: 'date DESC',
        offset: offset,
        limit: limit,
      );

      final collections = <DailyCollection>[];

      for (final row in collectionRows) {
        final dateString = row['date'] as String;
        final itemRows = await _db.query(
          'content_items',
          where: 'collection_date = ?',
          whereArgs: [dateString],
          orderBy: 'timestamp DESC',
        );

        final items = itemRows
            .map((itemRow) {
              final json = Map<String, dynamic>.from(itemRow);
              // Fix the content_type field for fromJson compatibility
              json['contentType'] = json['content_type'];
              json.remove('content_type');
              return SharedContent.fromJson(json);
            })
            .toList();

        final date = DateTime.parse(dateString);
        collections.add(DailyCollection(
          date: date,
          items: items,
        ));
      }

      return collections;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting all collections: $e');
      return [];
    }
  }

  /// Get total count of collections
  Future<int> getCollectionsCount() async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM collections',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Save a collection
  Future<void> saveCollection(DailyCollection collection) async {
    try {
      final dateString = collection.date.toIso8601String().split('T')[0];
      final now = DateTime.now().toIso8601String();

      // Insert or update collection
      await _db.insert(
        'collections',
        {
          'date': dateString,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete existing items for this date
      await _db.delete(
        'content_items',
        where: 'collection_date = ?',
        whereArgs: [dateString],
      );

      // Insert all items
      for (final item in collection.items) {
        await _db.insert(
          'content_items',
          {
            'id': item.id,
            'collection_date': dateString,
            'content_type': item.contentType.toString(),
            'title': item.title,
            'description': item.description,
            'timestamp': item.timestamp.toIso8601String(),
            'source': item.source,
            'content_data': item.contentData,
            'mime_type': item.mimeType,
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error saving collection: $e');
    }
  }

  /// Remove content from a collection
  Future<void> removeContent(DateTime date, String contentId) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      await _db.delete(
        'content_items',
        where: 'collection_date = ? AND id = ?',
        whereArgs: [dateString, contentId],
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error removing content: $e');
    }
  }

  /// Delete an entire collection
  Future<void> deleteCollection(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      await _db.delete(
        'collections',
        where: 'date = ?',
        whereArgs: [dateString],
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting collection: $e');
    }
  }

  /// Delete collections older than the specified duration
  Future<int> deleteOlderThan(Duration duration) async {
    try {
      final cutoffDate = DateTime.now().subtract(duration);
      final dateString = cutoffDate.toIso8601String().split('T')[0];
      return await _db.delete(
        'collections',
        where: 'date < ?',
        whereArgs: [dateString],
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting old collections: $e');
      return 0;
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _db.delete('content_items');
      await _db.delete('collections');
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing all data: $e');
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final collectionCount = await getCollectionsCount();
      final itemCountResult = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM content_items',
      );
      final itemCount = Sqflite.firstIntValue(itemCountResult) ?? 0;

      return {
        'total_collections': collectionCount,
        'total_items': itemCount,
      };
    } catch (e) {
      return {'total_collections': 0, 'total_items': 0};
    }
  }

  /// Close the database connection
  Future<void> close() async {
    await _db.close();
  }

  /// Check if welcome screen has been shown
  Future<bool> hasSeenWelcome() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('welcome_screen_shown') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark welcome screen as shown
  Future<void> setWelcomeShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('welcome_screen_shown', true);
    } catch (e) {
      // ignore: avoid_print
      print('Error setting welcome shown: $e');
    }
  }
}
