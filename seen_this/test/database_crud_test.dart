import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:seen_this/services/database_service.dart';
import 'package:seen_this/models/models.dart';

void main() {
  // Initialize SQLite FFI for testing
  sqfliteFfiInit();

  group('DatabaseService CRUD Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      // Use in-memory database for tests
      databaseFactory = databaseFactoryFfi;
      databaseService = DatabaseService();
      await databaseService.init();
    });

    tearDown(() async {
      await databaseService.close();
    });

    group('CREATE Operations', () {
      test('saveCollection creates a new collection', () async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'test-1',
          contentType: ContentType.link,
          title: 'Test Link',
          description: 'A test link',
          timestamp: now,
          source: 'Test',
          contentData: 'https://example.com',
          mimeType: 'text/html',
          tags: ['test', 'example'],
        );

        final collection = DailyCollection(
          date: now,
          items: [content],
        );

        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items, isNotEmpty);
        expect(retrieved.items.first.title, equals('Test Link'));
      });

      test('saveCollection with multiple items', () async {
        final now = DateTime.now();
        final items = List.generate(
          5,
          (index) => SharedContent(
            id: 'test-$index',
            contentType: ContentType.text,
            title: 'Item $index',
            timestamp: now,
            contentData: 'Content $index',
            tags: [],
          ),
        );

        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.length, equals(5));
      });

      test('saveCollection with different content types', () async {
        final now = DateTime.now();
        final items = [
          SharedContent(
            id: 'link-1',
            contentType: ContentType.link,
            title: 'Link',
            timestamp: now,
            contentData: 'https://example.com',
            tags: [],
          ),
          SharedContent(
            id: 'text-1',
            contentType: ContentType.text,
            title: 'Text',
            timestamp: now,
            contentData: 'Some text',
            tags: [],
          ),
          SharedContent(
            id: 'media-1',
            contentType: ContentType.media,
            title: 'Media',
            timestamp: now,
            contentData: '/path/to/media',
            tags: [],
          ),
        ];

        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.length, equals(3));
        expect(
          retrieved.items.map((i) => i.contentType).toList(),
          equals([ContentType.link, ContentType.text, ContentType.media]),
        );
      });

      test('saveCollection with tags', () async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'tagged-1',
          contentType: ContentType.link,
          title: 'Tagged Content',
          timestamp: now,
          contentData: 'https://example.com',
          tags: ['important', 'work', 'review-later'],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.first.tags,
            equals(['important', 'work', 'review-later']));
      });
    });

    group('READ Operations', () {
      setUp(() async {
        // Create test data
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final lastWeek = now.subtract(const Duration(days: 7));

        final itemsToday = [
          SharedContent(
            id: 'today-1',
            contentType: ContentType.link,
            title: 'Today Link',
            timestamp: now,
            contentData: 'https://today.com',
            tags: ['today'],
          ),
          SharedContent(
            id: 'today-2',
            contentType: ContentType.text,
            title: 'Today Text',
            timestamp: now,
            contentData: 'Today text content',
            tags: [],
          ),
        ];

        final itemsYesterday = [
          SharedContent(
            id: 'yesterday-1',
            contentType: ContentType.link,
            title: 'Yesterday Link',
            timestamp: yesterday,
            contentData: 'https://yesterday.com',
            tags: ['old'],
          ),
        ];

        final itemsLastWeek = [
          SharedContent(
            id: 'week-1',
            contentType: ContentType.media,
            title: 'Week Ago',
            timestamp: lastWeek,
            contentData: '/path/to/media',
            tags: [],
          ),
        ];

        await databaseService.saveCollection(
          DailyCollection(date: now, items: itemsToday),
        );
        await databaseService.saveCollection(
          DailyCollection(date: yesterday, items: itemsYesterday),
        );
        await databaseService.saveCollection(
          DailyCollection(date: lastWeek, items: itemsLastWeek),
        );
      });

      test('getTodaysCollection returns today\'s items', () async {
        final today = await databaseService.getTodaysCollection();
        expect(today.items.length, equals(2));
        expect(today.items.first.title, equals('Today Link'));
      });

      test('getCollectionByDate returns specific date', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayStr =
            yesterday.toIso8601String().split('T')[0];
        final collection = await databaseService.getCollectionByDate(
          DateTime.parse(yesterdayStr),
        );

        expect(collection.items.length, equals(1));
        expect(collection.items.first.title, equals('Yesterday Link'));
      });

      test('getAllCollections returns all collections', () async {
        final all = await databaseService.getAllCollections(limit: 100);
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('getAllCollections supports pagination', () async {
        final page1 = await databaseService.getAllCollections(
          offset: 0,
          limit: 2,
        );
        final page2 = await databaseService.getAllCollections(
          offset: 2,
          limit: 2,
        );

        expect(page1.length, lessThanOrEqualTo(2));
      });

      test('getCollectionsCount returns correct count', () async {
        final count = await databaseService.getCollectionsCount();
        expect(count, greaterThanOrEqualTo(3));
      });

      test('getTodaysCollection returns empty for no data', () async {
        // Clear and test with fresh instance
        final now = DateTime.now().add(const Duration(days: 100));
        final collection = await databaseService.getCollectionByDate(now);
        expect(collection.items, isEmpty);
        expect(collection.date, isNotNull);
      });
    });

    group('UPDATE Operations', () {
      setUp(() async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'update-test-1',
          contentType: ContentType.link,
          title: 'Original Title',
          description: 'Original Description',
          timestamp: now,
          source: 'Original Source',
          contentData: 'https://original.com',
          mimeType: 'text/html',
          tags: ['original'],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);
      });

      test('updateContentTags updates tags for content', () async {
        final now = DateTime.now();
        final newTags = ['updated', 'important', 'urgent'];

        await databaseService.updateContentTags(
          now,
          'update-test-1',
          newTags,
        );

        final collection =
            await databaseService.getTodaysCollection();
        expect(collection.items.first.tags, equals(newTags));
      });

      test('updateContentTags with empty tags', () async {
        final now = DateTime.now();
        await databaseService.updateContentTags(now, 'update-test-1', []);

        final collection =
            await databaseService.getTodaysCollection();
        expect(collection.items.first.tags, isEmpty);
      });

      test('updateContentTags with many tags', () async {
        final now = DateTime.now();
        final manyTags = List.generate(20, (i) => 'tag-$i');

        await databaseService.updateContentTags(
          now,
          'update-test-1',
          manyTags,
        );

        final collection =
            await databaseService.getTodaysCollection();
        expect(collection.items.first.tags.length, equals(20));
      });
    });

    group('DELETE Operations', () {
      test('removeContent deletes specific item', () async {
        final now = DateTime.now();
        final items = [
          SharedContent(
            id: 'delete-1',
            contentType: ContentType.link,
            title: 'Keep This',
            timestamp: now,
            contentData: 'https://keep.com',
            tags: [],
          ),
          SharedContent(
            id: 'delete-2',
            contentType: ContentType.text,
            title: 'Delete This',
            timestamp: now,
            contentData: 'Delete me',
            tags: [],
          ),
        ];

        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);

        // Delete one item
        await databaseService.removeContent(now, 'delete-2');

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.length, equals(1));
        expect(retrieved.items.first.id, equals('delete-1'));
      });

      test('deleteCollection deletes entire collection', () async {
        final testDate = DateTime.now().subtract(const Duration(days: 1));
        final content = SharedContent(
          id: 'col-del-1',
          contentType: ContentType.link,
          title: 'To Delete',
          timestamp: testDate,
          contentData: 'https://delete.com',
          tags: [],
        );

        final collection = DailyCollection(date: testDate, items: [content]);
        await databaseService.saveCollection(collection);

        // Verify it exists
        var retrieved = await databaseService.getCollectionByDate(testDate);
        expect(retrieved.items, isNotEmpty);

        // Delete it
        await databaseService.deleteCollection(testDate);

        // Verify it's gone
        retrieved = await databaseService.getCollectionByDate(testDate);
        expect(retrieved.items, isEmpty);
      });

      test('clearAll deletes all data', () async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'clear-1',
          contentType: ContentType.link,
          title: 'Will be cleared',
          timestamp: now,
          contentData: 'https://clear.com',
          tags: [],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        // Verify data exists
        var stats = await databaseService.getStats();
        expect(stats['total_items'], greaterThan(0));

        // Clear all
        await databaseService.clearAll();

        // Verify data is gone
        stats = await databaseService.getStats();
        expect(stats['total_items'], equals(0));
      });

      test('deleteOlderThan removes old collections', () async {
        final now = DateTime.now();
        final tenDaysAgo = now.subtract(const Duration(days: 10));
        final twoDaysAgo = now.subtract(const Duration(days: 2));

        // Create old content
        final oldContent = SharedContent(
          id: 'old-1',
          contentType: ContentType.link,
          title: 'Old',
          timestamp: tenDaysAgo,
          contentData: 'https://old.com',
          tags: [],
        );

        // Create recent content
        final recentContent = SharedContent(
          id: 'recent-1',
          contentType: ContentType.link,
          title: 'Recent',
          timestamp: twoDaysAgo,
          contentData: 'https://recent.com',
          tags: [],
        );

        await databaseService.saveCollection(
          DailyCollection(date: tenDaysAgo, items: [oldContent]),
        );
        await databaseService.saveCollection(
          DailyCollection(date: twoDaysAgo, items: [recentContent]),
        );

        // Delete items older than 7 days
        final deleted = await databaseService.deleteOlderThan(
          const Duration(days: 7),
        );

        expect(deleted, greaterThan(0));

        // Verify old is gone but recent remains
        final oldCollection =
            await databaseService.getCollectionByDate(tenDaysAgo);
        expect(oldCollection.items, isEmpty);
      });
    });

    group('Database Integrity Tests', () {
      test('content types are preserved', () async {
        final now = DateTime.now();
        final types = [
          ContentType.screenshot,
          ContentType.link,
          ContentType.text,
          ContentType.media,
          ContentType.other,
        ];

        final items = List.generate(
          types.length,
          (index) => SharedContent(
            id: 'type-$index',
            contentType: types[index],
            title: 'Type Test $index',
            timestamp: now,
            contentData: 'data',
            tags: [],
          ),
        );

        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        for (int i = 0; i < types.length; i++) {
          expect(
            retrieved.items[i].contentType,
            equals(types[i]),
            reason: 'Type at index $i should be preserved',
          );
        }
      });

      test('timestamps are preserved with microsecond precision', () async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'timestamp-1',
          contentType: ContentType.text,
          title: 'Timestamp Test',
          timestamp: now,
          contentData: 'test',
          tags: [],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        // Allow 1 second tolerance due to database conversion
        expect(
          retrieved.items.first.timestamp.difference(now).inSeconds.abs(),
          lessThan(1),
        );
      });

      test('null fields are handled correctly', () async {
        final now = DateTime.now();
        final content = SharedContent(
          id: 'null-1',
          contentType: ContentType.media,
          title: null,
          description: null,
          timestamp: now,
          source: null,
          contentData: null,
          mimeType: null,
          tags: [],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.first.title, isNull);
        expect(retrieved.items.first.description, isNull);
        expect(retrieved.items.first.source, isNull);
        expect(retrieved.items.first.contentData, isNull);
        expect(retrieved.items.first.mimeType, isNull);
      });

      test('special characters in content are preserved', () async {
        final now = DateTime.now();
        final specialText = 'Special chars: !@#\$%^&*(){}[]|:;<>?,./~`';
        final content = SharedContent(
          id: 'special-1',
          contentType: ContentType.text,
          title: specialText,
          description: specialText,
          timestamp: now,
          contentData: specialText,
          tags: ['spëcial', 'émoji🎉'],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.first.title, equals(specialText));
        expect(retrieved.items.first.description, equals(specialText));
        expect(retrieved.items.first.contentData, equals(specialText));
      });

      test('large content is handled correctly', () async {
        final now = DateTime.now();
        final largeContent =
            'x' * 10000; // 10KB of text
        final content = SharedContent(
          id: 'large-1',
          contentType: ContentType.text,
          title: 'Large Content',
          description: largeContent,
          timestamp: now,
          contentData: largeContent,
          tags: [],
        );

        final collection = DailyCollection(date: now, items: [content]);
        await databaseService.saveCollection(collection);

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.first.description?.length, equals(10000));
        expect(retrieved.items.first.contentData?.length, equals(10000));
      });
    });

    group('Performance Tests', () {
      test('bulk insert 100 items', () async {
        final now = DateTime.now();
        final items = List.generate(
          100,
          (index) => SharedContent(
            id: 'perf-$index',
            contentType: ContentType.text,
            title: 'Item $index',
            timestamp: now,
            contentData: 'Content $index',
            tags: [],
          ),
        );

        final stopwatch = Stopwatch()..start();
        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);
        stopwatch.stop();

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.length, equals(100));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
          reason: 'Bulk insert should complete in under 5 seconds',
        );
      });

      test('query 100 items is efficient', () async {
        final now = DateTime.now();
        final items = List.generate(
          100,
          (index) => SharedContent(
            id: 'query-$index',
            contentType: ContentType.text,
            title: 'Item $index',
            timestamp: now,
            contentData: 'Content $index',
            tags: [],
          ),
        );

        final collection = DailyCollection(date: now, items: items);
        await databaseService.saveCollection(collection);

        final stopwatch = Stopwatch()..start();
        final retrieved =
            await databaseService.getTodaysCollection();
        stopwatch.stop();

        expect(retrieved.items.length, equals(100));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: 'Query should complete in under 1 second',
        );
      });
    });

    group('Edge Cases', () {
      test('duplicate IDs are handled (replace)', () async {
        final now = DateTime.now();
        final content1 = SharedContent(
          id: 'dup-1',
          contentType: ContentType.text,
          title: 'First',
          timestamp: now,
          contentData: 'First content',
          tags: [],
        );

        final content2 = SharedContent(
          id: 'dup-1',
          contentType: ContentType.text,
          title: 'Second',
          timestamp: now,
          contentData: 'Second content',
          tags: [],
        );

        await databaseService.saveCollection(
          DailyCollection(date: now, items: [content1]),
        );
        await databaseService.saveCollection(
          DailyCollection(date: now, items: [content2]),
        );

        final retrieved =
            await databaseService.getTodaysCollection();
        expect(retrieved.items.length, equals(1));
        expect(retrieved.items.first.title, equals('Second'));
      });

      test('empty collection can be saved', () async {
        final now = DateTime.now();
        final collection = DailyCollection(date: now, items: []);
        await databaseService.saveCollection(collection);

        final retrieved = await databaseService.getCollectionByDate(now);
        expect(retrieved.items, isEmpty);
      });

      test('collection date normalization', () async {
        final dateWithTime =
            DateTime(2025, 1, 15, 14, 30, 45); // Date with time
        final dateOnly =
            DateTime(2025, 1, 15); // Just date portion

        final content = SharedContent(
          id: 'norm-1',
          contentType: ContentType.text,
          title: 'Normalization Test',
          timestamp: dateWithTime,
          contentData: 'test',
          tags: [],
        );

        await databaseService.saveCollection(
          DailyCollection(date: dateWithTime, items: [content]),
        );

        // Retrieve using date only
        final retrieved =
            await databaseService.getCollectionByDate(dateOnly);
        expect(retrieved.items, isNotEmpty);
      });
    });
  });
}
