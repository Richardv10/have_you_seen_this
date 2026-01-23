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
  static Function(String error)? _onError;

  /// Setup listener for shared text and links
  static void setupTextListener(
    CollectionsNotifier collectionsNotifier, {
    Function(String error)? onError,
  }) {
    _collectionsNotifier = collectionsNotifier;
    _onError = onError;
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
  static void setupMediaListener(
    CollectionsNotifier collectionsNotifier, {
    Function(String error)? onError,
  }) {
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
      String? title;
      String? description;
      
      if (contentType == ContentType.link) {
        try {
          // ignore: avoid_print
          print('🌐 Fetching metadata for: $sharedText');
          
          final metadata = await LinkPreviewService.getMetadata(sharedText);
          
          if (metadata != null) {
            // Use metadata title if available
            if (metadata.title != null && metadata.title!.isNotEmpty) {
              title = metadata.title;
              // ignore: avoid_print
              print('✅ Got title from metadata: $title');
            }
            
            // Use metadata description if available
            if (metadata.description != null && metadata.description!.isNotEmpty) {
              description = metadata.description;
              // ignore: avoid_print
              print('✅ Got description from metadata');
            }
          }
          
          // Fallback if no title from metadata
          if (title == null || title.isEmpty) {
            // ignore: avoid_print
            print('⚠️ No title in metadata, extracting domain');
            title = Uri.parse(sharedText).host.replaceFirst('www.', '');
            if (title.isEmpty) {
              title = 'Shared Link';
            }
          }
        } catch (e) {
          // Silent failure, use domain or default title
          // ignore: avoid_print
          print('❌ Error fetching metadata: $e');
          try {
            title = Uri.parse(sharedText).host.replaceFirst('www.', '');
            if (title.isEmpty) {
              title = 'Shared Link';
            }
          } catch (_) {
            title = 'Shared Link';
          }
        }
      } else {
        title = 'Shared Text';
        description = sharedText;
      }

      // For links, use the URL as description if we didn't get one from metadata
      if (contentType == ContentType.link && (description == null || description.isEmpty)) {
        description = sharedText;
      }

      await collectionsNotifier.addContentToday(
        contentType,
        title: title,
        description: description ?? sharedText,
        contentData: contentType == ContentType.link ? sharedText : null,
      );

      // ignore: avoid_print
      print('✅ Added shared text content to today\'s collection');
    } catch (e) {
      final errorMsg = 'Error handling shared text: $e';
      // ignore: avoid_print
      print('❌ $errorMsg');
      _onError?.call(errorMsg);
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
      final errorMsg = 'Error handling shared media: $e';
      // ignore: avoid_print
      print('❌ $errorMsg');
      _onError?.call(errorMsg);
    }
  }

  /// Cleanup listeners when app closes
  static void dispose() {
    // Cleanup if needed
  }
}


