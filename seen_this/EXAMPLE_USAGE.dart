// Example usage of the seen_this app models and services
// This is for reference to understand how the app works

import 'package:seen_this/models/models.dart';
import 'package:seen_this/services/storage_service.dart';
import 'package:seen_this/providers/collections_notifier.dart';

/// Example demonstrating how content flows through the app
void exampleUsage() async {
  // Initialize storage
  final storage = StorageService();
  await storage.init();

  // Example 1: Create a new shared content item
  final link = SharedContent(
    id: '1',
    contentType: ContentType.link,
    title: 'Funny meme',
    description: 'Check out this hilarious post',
    timestamp: DateTime.now(),
    source: 'Twitter',
    contentData: 'https://twitter.com/someone/status/123456789',
    mimeType: 'text/plain',
  );

  // Example 2: Save to today's collection
  await storage.addToTodaysCollection(link);

  // Example 3: Get today's collection
  final today = await storage.getTodaysCollection();
  print('Today we have ${today.count} items');
  print('Date: ${today.formattedDate}');

  // Example 4: Create screenshot content
  final screenshot = SharedContent(
    id: '2',
    contentType: ContentType.screenshot,
    title: 'Funny screenshot',
    timestamp: DateTime.now(),
    source: 'Instagram',
    contentData: '/path/to/image.jpg',
    mimeType: 'image/jpeg',
  );

  await storage.addToTodaysCollection(screenshot);

  // Example 5: Get all collections
  final allCollections = await storage.getAllCollections();
  print('Total collections: ${allCollections.length}');
  for (final collection in allCollections) {
    print('${collection.formattedDate}: ${collection.count} items');
  }

  // Example 6: Remove specific content
  await storage.removeContent(today.date, link.id);

  // Example 7: Get collection for specific date
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final yesterdayCollection = await storage.getCollectionByDate(yesterday);
  print('Yesterday: ${yesterdayCollection.count} items');

  // Example 8: Get statistics
  final stats = await storage.getStats();
  print('Total collections: ${stats['totalCollections']}');
  print('Total items: ${stats['totalItems']}');

  // Example 9: Delete entire collection
  await storage.deleteCollection(yesterday);

  // Example 10: Using the notifier (in Flutter widgets)
  // final notifier = CollectionsNotifier(storage);
  // await notifier.init();
  //
  // // Add content
  // await notifier.addContentToday(
  //   ContentType.link,
  //   title: 'New Link',
  //   description: 'https://example.com',
  //   source: 'Browser',
  //   contentData: 'https://example.com',
  // );
  //
  // // Access collections
  // final collections = notifier.collections;
  // final todayCollection = notifier.todayCollection;
}

/// Example of how share intent service processes incoming content
void exampleShareIntentFlow() {
  // When user shares a link from Chrome:
  // 1. Android system receives the SEND intent
  // 2. User selects "seen_this" from share menu
  // 3. ShareIntentService.listenForSharedText() is called
  // 4. Service detects it's a link (starts with http:// or https://)
  // 5. CollectionsNotifier.addContentToday() is called with ContentType.link
  // 6. StorageService saves to today's collection
  // 7. UI updates automatically via Provider ChangeNotifier
  // 8. User sees new item in Today screen

  // When user shares a screenshot from Gallery:
  // 1. Android system receives the SEND intent
  // 2. User selects "seen_this"
  // 3. ShareIntentService.listenForSharedMedia() is called
  // 4. Service checks file extension
  // 5. Determines content type (screenshot/media)
  // 6. Saves file path and metadata
  // 7. UI updates with thumbnail/icon
}

/// Example data structure after saving
void exampleDataStructure() {
  // In SharedPreferences, data is stored as JSON:
  // Key: 'daily_collections'
  // Value:
  // [
  //   {
  //     "date": "2026-01-06T00:00:00.000Z",
  //     "items": [
  //       {
  //         "id": "uuid-1234",
  //         "contentType": "ContentType.link",
  //         "title": "Funny meme",
  //         "description": "Check this out",
  //         "timestamp": "2026-01-06T14:30:00.000Z",
  //         "source": "Twitter",
  //         "contentData": "https://twitter.com/...",
  //         "mimeType": "text/plain"
  //       },
  //       {
  //         "id": "uuid-5678",
  //         "contentType": "ContentType.screenshot",
  //         "title": "Shared screenshot",
  //         "timestamp": "2026-01-06T15:45:00.000Z",
  //         "source": "Instagram",
  //         "contentData": "/path/to/image.jpg",
  //         "mimeType": "image/jpeg"
  //       }
  //     ]
  //   },
  //   {
  //     "date": "2026-01-05T00:00:00.000Z",
  //     "items": [...]
  //   }
  // ]
}
