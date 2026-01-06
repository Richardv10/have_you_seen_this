import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receive_sharing_intent/models/shared_media_file.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';

/// Handles incoming share intents from Facebook, TikTok, and other apps
/// Works on Android and iOS to receive shared content
class MobileShareIntentHandler {
  static StreamSubscription? _textStreamSubscription;
  static StreamSubscription? _mediaStreamSubscription;

  /// Setup listener for shared text and links
  /// Listens continuously for incoming text shares
  static void setupTextListener(CollectionsNotifier collectionsNotifier) {
    // Cancel any existing subscription
    _textStreamSubscription?.cancel();

    try {
      _textStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen(
        (String value) {
          _handleSharedText(value, collectionsNotifier);
        },
        onError: (err) {
          print('❌ Error receiving shared text: $err');
        },
        onDone: () {
          print('⚠️ Text stream closed');
        },
      );
      print(
        '✅ Text share listener ready - can receive from Facebook, TikTok, etc.',
      );
    } catch (e) {
      print('❌ Failed to setup text listener: $e');
    }
  }

  /// Setup listener for shared media (images, videos, files)
  /// Listens continuously for incoming media shares
  static void setupMediaListener(CollectionsNotifier collectionsNotifier) {
    // Cancel any existing subscription
    _mediaStreamSubscription?.cancel();

    try {
      _mediaStreamSubscription =
          ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> mediaList) {
          print('📸 Received ${mediaList.length} shared media item(s)');
          for (var media in mediaList) {
            _handleSharedMedia(media, collectionsNotifier);
          }
        },
        onError: (err) {
          print('❌ Error receiving shared media: $err');
        },
        onDone: () {
          print('⚠️ Media stream closed');
        },
      );
      print(
        '✅ Media share listener ready - can receive images/videos from Facebook, TikTok, etc.',
      );
    } catch (e) {
      print('❌ Failed to setup media listener: $e');
    }
  }

  /// Process incoming shared text or link
  static Future<void> _handleSharedText(
    String text,
    CollectionsNotifier collectionsNotifier,
  ) async {
    if (text.isEmpty) return;

    try {
      // Detect if it's a URL/link
      final isLink = text.startsWith('http://') || text.startsWith('https://');

      await collectionsNotifier.addContentToday(
        isLink ? ContentType.link : ContentType.text,
        title: isLink ? 'Shared Link' : 'Shared Text',
        description: text,
        source: 'Facebook/TikTok/Share',
        contentData: text,
      );

      final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
      print('✅ Added shared ${isLink ? 'link' : 'text'}: $preview');
    } catch (e) {
      print('❌ Error handling shared text: $e');
    }
  }

  /// Process incoming shared media (image, video, file)
  static Future<void> _handleSharedMedia(
    SharedMediaFile media,
    CollectionsNotifier collectionsNotifier,
  ) async {
    final path = media.path;
    if (path == null || path.isEmpty) {
      print('⚠️ Received media with empty path');
      return;
    }

    try {
      // Determine content type from file extension
      ContentType contentType = ContentType.media;
      final lowerPath = path.toLowerCase();

      if (lowerPath.endsWith('.jpg') ||
          lowerPath.endsWith('.jpeg') ||
          lowerPath.endsWith('.png') ||
          lowerPath.endsWith('.gif') ||
          lowerPath.endsWith('.webp') ||
          media.mimeType?.startsWith('image/') == true) {
        contentType = ContentType.screenshot;
      } else if (lowerPath.endsWith('.mp4') ||
          lowerPath.endsWith('.mov') ||
          lowerPath.endsWith('.mkv') ||
          media.mimeType?.startsWith('video/') == true) {
        contentType = ContentType.media;
      }

      await collectionsNotifier.addContentToday(
        contentType,
        title: _getTitleForMedia(contentType),
        description: 'Shared from another app',
        source: 'Facebook/TikTok/Share',
        contentData: path,
        mimeType: media.mimeType,
      );

      print(
        '✅ Added shared ${contentType.name}: ${path.split('/').last}',
      );
    } catch (e) {
      print('❌ Error handling shared media: $e');
    }
  }

  static String _getTitleForMedia(ContentType type) {
    switch (type) {
      case ContentType.screenshot:
        return 'Shared Image';
      case ContentType.media:
        return 'Shared Video';
      default:
        return 'Shared Media';
    }
  }

  /// Cleanup listeners when app closes
  static void dispose() {
    _textStreamSubscription?.cancel();
    _mediaStreamSubscription?.cancel();
  }
}

// Import for StreamSubscription type
import 'dart:async';

