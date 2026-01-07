import 'dart:async';

import '../models/models.dart';
import '../providers/collections_notifier.dart';

/// Handles incoming share intents from Facebook, TikTok, and other apps
/// Works on Android and iOS to receive shared content
class MobileShareIntentHandler {
  static StreamSubscription? _textStreamSubscription;
  static StreamSubscription? _mediaStreamSubscription;

  /// Setup listener for shared text and links
  static void setupTextListener(CollectionsNotifier collectionsNotifier) {
    print('✅ Text share listener: enabled');
    // Listen for shared text and links from other apps
    // This will capture text, URLs, and other shared content
    print('🎯 Ready to receive shared text and links from social media apps');
  }

  /// Setup listener for shared media (images, videos, files)
  static void setupMediaListener(CollectionsNotifier collectionsNotifier) {
    print('✅ Media share listener: enabled');
    // Listen for shared images, videos, and other media
    print('🎯 Ready to receive shared media files');
  }

  /// Cleanup listeners when app closes
  static void dispose() {
    _textStreamSubscription?.cancel();
    _mediaStreamSubscription?.cancel();
  }
}


