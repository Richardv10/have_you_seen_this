import 'package:flutter/material.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';

/// Service to handle incoming shared content from other apps
/// Note: This is a stub version for Windows/desktop testing.
/// On Android/iOS, the actual receive_sharing_intent would be used.
class ShareIntentService {
  /// Listen for shared content and add to today's collection
  /// Stub version - returns immediately on non-mobile platforms
  static void listenForSharedContent(
    BuildContext context,
    CollectionsNotifier collectionsNotifier,
  ) {
    // Stub: Share intent is handled natively on Android/iOS
    // For development/testing on Windows, use the UI button to add content
    print('Share intent listener initialized (desktop mode)');
  }

  /// Helper method to manually add test content
  /// Use this to test the app without needing actual share intent
  static Future<void> addTestContent(
    CollectionsNotifier collectionsNotifier,
    ContentType type, {
    String? title,
    String? description,
    String? source,
  }) async {
    await collectionsNotifier.addContentToday(
      type,
      title: title ?? _defaultTitle(type),
      description: description ?? _defaultDescription(type),
      source: source ?? 'Test',
    );
  }

  static String _defaultTitle(ContentType type) {
    switch (type) {
      case ContentType.link:
        return 'Test Link';
      case ContentType.screenshot:
        return 'Test Screenshot';
      case ContentType.text:
        return 'Test Text';
      case ContentType.media:
        return 'Test Media';
      case ContentType.other:
        return 'Test Content';
    }
  }

  static String _defaultDescription(ContentType type) {
    switch (type) {
      case ContentType.link:
        return 'https://example.com - A test link';
      case ContentType.screenshot:
        return 'This is a test screenshot';
      case ContentType.text:
        return 'This is some test text content that was shared';
      case ContentType.media:
        return 'A test media file';
      case ContentType.other:
        return 'Other test content';
    }
  }
}


