import 'package:flutter/material.dart';
import '../providers/collections_notifier.dart';
import 'mobile_share_intent_handler.dart';

/// Service to manage incoming share intents from social media apps
/// On Android/iOS: Listens for shares from Facebook, TikTok, Instagram, etc.
class ShareIntentService {
  /// Callback for handling share intent errors
  static Function(String error)? _onError;

  /// Initialize share intent listening
  /// Call this in main.dart's initState to start receiving shares
  static void listenForSharedContent(
    BuildContext context,
    CollectionsNotifier collectionsNotifier, {
    Function(String error)? onError,
  }) {
    _onError = onError;
    
    // Setup listeners for both text and media shares
    try {
      MobileShareIntentHandler.setupTextListener(
        collectionsNotifier,
        onError: _handleError,
      );
      MobileShareIntentHandler.setupMediaListener(
        collectionsNotifier,
        onError: _handleError,
      );

      // ignore: avoid_print
      print(
        '🚀 Share intent service initialized - app can now receive shares from social media',
      );
    } catch (e) {
      _handleError('Failed to initialize share intent listeners: $e');
    }
  }

  /// Handle errors from share intent listeners
  static void _handleError(String error) {
    // ignore: avoid_print
    print('⚠️ Share intent error: $error');
    _onError?.call(error);
  }

  /// Cleanup resources when app closes
  static void dispose() {
    MobileShareIntentHandler.dispose();
  }
}


