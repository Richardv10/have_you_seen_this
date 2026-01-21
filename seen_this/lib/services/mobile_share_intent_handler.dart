import 'dart:async';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../providers/collections_notifier.dart';
import 'link_preview_service.dart';

/// Handles incoming share intents from Facebook, TikTok, and other apps
/// Works on Android and iOS to receive shared content
class MobileShareIntentHandler {
  static const platform = MethodChannel('com.example.seen_this/share');
  static CollectionsNotifier? _collectionsNotifier;

  /// Setup listener for shared text and links
  static void setupTextListener(CollectionsNotifier collectionsNotifier) {
    _collectionsNotifier = collectionsNotifier;
    // ignore: avoid_print
    print('✅ Text share listener: enabled');
    
    // Check if the app was opened via a share intent
    _checkForSharedContent();
    
    // Listen for incoming share intents
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onShareReceived') {
        final String? sharedText = call.arguments as String?;
        if (sharedText != null && sharedText.isNotEmpty) {
          // ignore: avoid_print
          print('📨 Received shared text: $sharedText');
          await _handleSharedText(sharedText, collectionsNotifier);
        }
      }
      return null;
    });
    
    // ignore: avoid_print
    print('🎯 Ready to receive shared text and links from social media apps');
  }

  /// Check for shared content when app is first opened
  static Future<void> _checkForSharedContent() async {
    try {
      // Check for shared text
      final String? sharedText = await platform.invokeMethod('getSharedText');
      if (sharedText != null && sharedText.isNotEmpty && _collectionsNotifier != null) {
        // ignore: avoid_print
        print('📨 Found shared content on app launch: $sharedText');
        await _handleSharedText(sharedText, _collectionsNotifier!);
      }
      
      // Check for shared media
      final String? sharedMediaPath = await platform.invokeMethod('getSharedMedia');
      if (sharedMediaPath != null && sharedMediaPath.isNotEmpty && _collectionsNotifier != null) {
        // ignore: avoid_print
        print('📸 Found shared media on app launch: $sharedMediaPath');
        await _handleSharedMedia(sharedMediaPath, _collectionsNotifier!);
      }
    } catch (e) {
      // ignore: avoid_print
      print('ℹ️ No shared content or error getting shared data: $e');
    }
  }

  /// Setup listener for shared media (images, videos, files)
  static void setupMediaListener(CollectionsNotifier collectionsNotifier) {
    // ignore: avoid_print
    print('✅ Media share listener: enabled');
    // ignore: avoid_print
    print('🎯 Ready to receive shared media files');
  }

  /// Handle incoming shared text/link
  static Future<void> _handleSharedText(
    String sharedText,
    CollectionsNotifier collectionsNotifier,
  ) async {
    try {
      final ContentType contentType = sharedText.startsWith('http')
          ? ContentType.link
          : ContentType.text;

      // For links, try to fetch the page title from Open Graph metadata
      String title = 'Shared Link';
      if (contentType == ContentType.link) {
        try {
          final metadata = await LinkPreviewService.getMetadata(sharedText);
          if (metadata?.title != null && metadata!.title!.isNotEmpty) {
            title = metadata.title!;
          }
        } catch (e) {
          // Silent failure, use default title
        }
      } else {
        title = 'Shared Text';
      }

      await collectionsNotifier.addContentToday(
        contentType,
        title: title,
        description: sharedText,
        source: 'Reshared via seen_this',
        contentData: contentType == ContentType.link ? sharedText : null,
      );

      // ignore: avoid_print
      print('✅ Added shared text content to today\'s collection');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error handling shared text: $e');
    }
  }

  /// Handle incoming shared media
  static Future<void> _handleSharedMedia(
    String mediaPath,
    CollectionsNotifier collectionsNotifier,
  ) async {
    try {
      final fileName = mediaPath.split('/').last;
      final extension = fileName.toLowerCase().split('.').last;
      
      // Determine if it's a video or image
      final videoExtensions = ['mp4', 'mkv', 'webm', 'avi', 'mov', 'flv', 'wmv'];
      final isVideo = videoExtensions.contains(extension);
      
      final title = isVideo ? 'Shared Video' : 'Shared Image';
      
      // ignore: avoid_print
      print('📸 Media path: $mediaPath');
      // ignore: avoid_print
      print('📸 Is content URI: ${mediaPath.startsWith('content://')}');
      
      await collectionsNotifier.addContentToday(
        ContentType.media,
        title: title,
        description: fileName,
        source: 'Shared',
        contentData: mediaPath, // Store the file path for thumbnail display
      );

      // ignore: avoid_print
      print('✅ Added shared media content to today\'s collection');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error handling shared media: $e');
    }
  }

  /// Cleanup listeners when app closes
  static void dispose() {
    // Cleanup if needed
  }
}


