import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

/// Service to handle resharing content via chat/IM and other apps
class ReshareService {
  /// Reshare content to other apps (WhatsApp, Telegram, SMS, Email, etc.)
  static Future<void> reshareContent(SharedContent content) async {
    final shareText = _buildShareText(content);
    final subject = content.title ?? 'Check this out';

    // Use Share.share for opening the system share sheet
    await Share.share(
      shareText,
      subject: subject,
    );
  }

  /// Reshare to specific app/intent
  /// This will open the system share dialog with available apps
  static Future<void> reshareToChat(SharedContent content) async {
    final shareText = _buildShareText(content);
    
    // This opens the native share sheet which includes all chat apps
    // available on the device (WhatsApp, Telegram, Signal, etc.)
    await Share.share(shareText);
  }

  /// Build formatted text for sharing
  static String _buildShareText(SharedContent content) {
    final buffer = StringBuffer();
    
    if (content.title != null && content.title!.isNotEmpty) {
      buffer.writeln(content.title);
    }
    
    if (content.source != null && content.source!.isNotEmpty) {
      buffer.writeln('From: ${content.source}');
    }
    
    if (content.description != null && content.description!.isNotEmpty) {
      buffer.writeln('\n${content.description}');
    }
    
    if (content.contentData != null && content.contentData!.isNotEmpty) {
      // If it's a URL, add it directly
      if (content.contentData!.startsWith('http')) {
        buffer.writeln('\n${content.contentData}');
      } else {
        // Otherwise add as part of description
        buffer.writeln('\n${content.contentData}');
      }
    }
    
    return buffer.toString();
  }

  /// Get share suggestion text with available messaging apps hint
  static String getShareHint(SharedContent content) {
    return 'Share "${content.title ?? 'content'}" via WhatsApp, Telegram, Email, or other apps';
  }
}
