import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';

/// Mobile-specific share intent implementation
/// This file is only compiled on Android/iOS
class MobileShareIntentHandler {
  /// Setup text sharing listener
  static void setupTextListener(CollectionsNotifier collectionsNotifier) {
    ReceiveSharingIntent.getTextStream().listen(
      (String value) {
        _handleSharedText(value, collectionsNotifier);
      },
      onError: (err) {
        print('Error receiving shared text: $err');
      },
    );
  }

  /// Setup media sharing listener
  static void setupMediaListener(CollectionsNotifier collectionsNotifier) {
    ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        for (var media in value) {
          _handleSharedMedia(media, collectionsNotifier);
        }
      },
      onError: (err) {
        print('Error receiving shared media: $err');
      },
    );
  }

  /// Handle shared text or links
  static Future<void> _handleSharedText(
    String text,
    CollectionsNotifier collectionsNotifier,
  ) async {
    if (text.isEmpty) return;

    // Detect if it's a link
    final isLink = text.startsWith('http://') || text.startsWith('https://');

    await collectionsNotifier.addContentToday(
      isLink ? ContentType.link : ContentType.text,
      title: isLink ? 'Shared Link' : 'Shared Text',
      description: text,
      source: 'Share Intent',
      contentData: text,
    );
  }

  /// Handle shared media (images, videos, etc.)
  static Future<void> _handleSharedMedia(
    SharedMediaFile media,
    CollectionsNotifier collectionsNotifier,
  ) async {
    final path = media.path;
    if (path == null || path.isEmpty) return;

    // Determine content type based on file extension
    ContentType contentType = ContentType.media;
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif')) {
      contentType = ContentType.screenshot;
    }

    await collectionsNotifier.addContentToday(
      contentType,
      title: 'Shared Media',
      source: 'Share Intent',
      contentData: path,
      mimeType: media.mimeType,
    );
  }
}
