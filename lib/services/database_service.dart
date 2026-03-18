import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for managing SQLite database operations
class DatabaseService {
  static const String _dbName = 'seen_this.db';
  static const int _dbVersion = 2;

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
        tags TEXT,
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
    if (oldVersion < 2) {
      // Add tags column to content_items table
      await db.execute('ALTER TABLE content_items ADD COLUMN tags TEXT');
    }
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
            // Fix all snake_case database fields to camelCase for model compatibility
            json['contentType'] = json['content_type'];
            json.remove('content_type');
            json['contentData'] = json['content_data'];
            json.remove('content_data');
            json['mimeType'] = json['mime_type'];
            json.remove('mime_type');
            // Handle tags: convert from comma-separated string to list
            final tagsStr = json['tags'] as String?;
            json['tags'] = tagsStr?.isNotEmpty == true ? tagsStr!.split(',') : [];
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
  /// OPTIMIZED: Uses single JOIN query instead of N+1 pattern
  Future<List<DailyCollection>> getAllCollections({
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      // Single optimized query with JOIN to fetch all data at once
      final result = await _db.rawQuery('''
        SELECT 
          c.date,
          c.created_at,
          c.updated_at,
          ci.id,
          ci.content_type,
          ci.title,
          ci.description,
          ci.timestamp,
          ci.source,
          ci.content_data,
          ci.mime_type,
          ci.tags,
          ci.created_at as item_created_at
        FROM collections c
        LEFT JOIN content_items ci ON c.date = ci.collection_date
        ORDER BY c.date DESC, ci.timestamp DESC
        LIMIT ? OFFSET ?
      ''', [limit, offset]);

      // Group results by collection date in Dart
      final Map<String, DailyCollection> collectionMap = {};
      
      for (final row in result) {
        final dateString = row['date'] as String;
        
        // Create collection entry if it doesn't exist
        if (!collectionMap.containsKey(dateString)) {
          collectionMap[dateString] = DailyCollection(
            date: DateTime.parse(dateString),
            items: [],
          );
        }
        
        // Add item to collection if it exists (not all rows will have items)
        if (row['id'] != null) {
          try {
            final json = Map<String, dynamic>.from(row);
            // Fix all snake_case database fields to camelCase for model compatibility
            json['contentType'] = json['content_type'];
            json.remove('content_type');
            json['contentData'] = json['content_data'];
            json.remove('content_data');
            json['mimeType'] = json['mime_type'];
            json.remove('mime_type');
            // Handle tags: convert from comma-separated string to list
            final tagsStr = json['tags'] as String?;
            json['tags'] = tagsStr?.isNotEmpty == true ? tagsStr!.split(',') : [];
            collectionMap[dateString]!.items.add(SharedContent.fromJson(json));
          } catch (e) {
            // Ignore individual item parsing errors
            // ignore: avoid_print
            print('Error parsing item: $e');
          }
        }
      }

      return collectionMap.values.toList();
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
            'tags': item.tags.isNotEmpty ? item.tags.join(',') : null,
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

  /// Update tags for a specific content item
  Future<void> updateContentTags(
    DateTime date,
    String contentId,
    List<String> tags,
  ) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final tagsString = tags.isNotEmpty ? tags.join(',') : null;
      
      await _db.update(
        'content_items',
        {'tags': tagsString},
        where: 'id = ? AND collection_date = ?',
        whereArgs: [contentId, dateString],
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error updating tags: $e');
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
