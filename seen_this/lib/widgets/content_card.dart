import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../services/reshare_service.dart';

/// Widget displaying a single piece of shared content
class ContentCard extends StatelessWidget {
  final SharedContent content;
  final VoidCallback onDelete;

  const ContentCard({
    super.key,
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onLongPress: () => _showOptions(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show thumbnail for media content
              if (content.contentType == ContentType.media && 
                  content.contentData != null &&
                  _isImageOrVideo(content.contentData!))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildMediaThumbnail(content.contentData!),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (content.title != null)
                          Text(
                            content.title!,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (content.source != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              content.source!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _ContentTypeIcon(type: content.contentType),
                  ),
                ],
              ),
              if (content.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    content.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  content.formattedTime,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if the file path is an image or video
  bool _isImageOrVideo(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final videoExtensions = ['mp4', 'mkv', 'webm', 'avi', 'mov', 'flv', 'wmv'];
    
    return imageExtensions.contains(extension) || 
           videoExtensions.contains(extension);
  }

  /// Build media thumbnail widget
  Widget _buildMediaThumbnail(String filePath) {
    try {
      final extension = filePath.toLowerCase().split('.').last;
      final videoExtensions = ['mp4', 'mkv', 'webm', 'avi', 'mov', 'flv', 'wmv'];
      final isVideo = videoExtensions.contains(extension);

      if (isVideo) {
        // Video thumbnail with play icon overlay
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(
                Icons.video_library,
                size: 64,
                color: Colors.grey,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        );
      } else {
        // Image thumbnail - check if it's a file path or a content URI
        if (filePath.startsWith('content://') || filePath.startsWith('file://')) {
          // It's a URI, try to load it
          return _buildImageFromUri(filePath);
        } else {
          // It's a file path
          try {
            final file = File(filePath);
            if (!file.existsSync()) {
              return _buildThumbnailPlaceholder('File not found');
            }
            return Image.file(
              file,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildThumbnailPlaceholder('Image error');
              },
            );
          } catch (e) {
            return _buildThumbnailPlaceholder('Cannot load file');
          }
        }
      }
    } catch (e) {
      return _buildThumbnailPlaceholder('Error loading media');
    }
  }

  /// Build image from URI (content:// or file://)
  Widget _buildImageFromUri(String uri) {
    return Image.network(
      uri,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildThumbnailPlaceholder('URI image error');
      },
    );
  }

  /// Build placeholder when thumbnail can't be loaded
  Widget _buildThumbnailPlaceholder(String message) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Options',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Reshare via Chat/IM'),
                subtitle: const Text('WhatsApp, Telegram, Email, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  _reshareContent(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareContent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Reshare content to chat/IM apps
  Future<void> _reshareContent(BuildContext context) async {
    try {
      await ReshareService.reshareContent(content);
      
      // Persist the reshared item to today's collection so it can be reshared again
      if (context.mounted) {
        final collectionsNotifier = context.read<CollectionsNotifier>();
        await collectionsNotifier.addContentToday(
          content.contentType,
          title: content.title,
          description: content.description,
          source: '${content.source} (reshared)',
          contentData: content.contentData,
          mimeType: content.mimeType,
        );
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reshared! Item saved to today\'s collection'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  /// Share the content using system share dialog
  Future<void> _shareContent() async {
    final shareText = _buildShareText();
    await Share.share(shareText);
  }

  /// Copy content to clipboard
  void _copyToClipboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  /// Build the text to share/copy
  String _buildShareText() {
    final buffer = StringBuffer();
    
    if (content.title != null) {
      buffer.writeln(content.title);
    }
    
    if (content.source != null) {
      buffer.writeln('From: ${content.source}');
    }
    
    if (content.description != null) {
      buffer.writeln('\n${content.description}');
    }
    
    if (content.contentData != null) {
      buffer.writeln('\n${content.contentData}');
    }
    
    buffer.writeln('\n—');
    buffer.writeln('Shared via seen_this');
    
    return buffer.toString();
  }
}

/// Widget to display content type icon
class _ContentTypeIcon extends StatelessWidget {
  final ContentType type;

  const _ContentTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case ContentType.screenshot:
        icon = Icons.screenshot;
        color = Colors.blue;
        break;
      case ContentType.link:
        icon = Icons.link;
        color = Colors.purple;
        break;
      case ContentType.text:
        icon = Icons.description;
        color = Colors.green;
        break;
      case ContentType.media:
        icon = Icons.image;
        color = Colors.orange;
        break;
      case ContentType.other:
        icon = Icons.folder;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
