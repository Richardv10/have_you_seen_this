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

  /// Cleanup resources when app closes
  static void dispose() {
    MobileShareIntentHandler.dispose();
  }
}


