import 'package:flutter/material.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import 'mobile_share_intent_handler.dart';

/// Service to manage incoming share intents from social media apps
/// On Android/iOS: Listens for shares from Facebook, TikTok, Instagram, etc.
class ShareIntentService {
  /// Initialize share intent listening
  /// Call this in main.dart's initState to start receiving shares
  static void listenForSharedContent(
    BuildContext context,
    CollectionsNotifier collectionsNotifier,
  ) {
    // Setup listeners for both text and media shares
    MobileShareIntentHandler.setupTextListener(collectionsNotifier);
    MobileShareIntentHandler.setupMediaListener(collectionsNotifier);

    print(
      '🚀 Share intent service initialized - app can now receive shares from social media',
    );
  }

  /// Manually add test content (for testing without sharing from another app)
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

  /// Cleanup resources when app closes
  static void dispose() {
    MobileShareIntentHandler.dispose();
  }
}


