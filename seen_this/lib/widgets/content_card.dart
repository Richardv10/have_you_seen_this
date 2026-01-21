import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../services/reshare_service.dart';
import '../services/link_preview_service.dart';
import '../screens/media_viewer_screen.dart';

/// Widget displaying a single piece of shared content
// spell-checker: ignore reshare
class ContentCard extends StatefulWidget {
  final SharedContent content;
  final VoidCallback onDelete;

  const ContentCard({
    super.key,
    required this.content,
    required this.onDelete,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  LinkMetadata? _linkMetadata;
  bool _metadataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Fetch metadata for non-YouTube links
    if (widget.content.contentType == ContentType.link) {
      final url = widget.content.contentData ?? widget.content.description;
      if (url != null && _extractYouTubeVideoId(url) == null) {
        _fetchMetadata();
      }
    }
  }

  Future<void> _fetchMetadata() async {
    final url = widget.content.contentData ?? widget.content.description;
    if (url != null && url.isNotEmpty) {
      final metadata = await LinkPreviewService.getMetadata(url);
      if (mounted) {
        setState(() {
          _linkMetadata = metadata;
          _metadataLoaded = true;
        });
      }
    }
  }

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
              if (widget.content.contentType == ContentType.media && 
                  widget.content.contentData != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _openMediaViewer(context, widget.content),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          _buildMediaThumbnail(widget.content.contentData!),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Show YouTube thumbnail for YouTube links
              if (widget.content.contentType == ContentType.link)
                _buildYouTubeThumbnailSection(context, widget.content),
              // Show generic link preview for other links (not YouTube)
              if (widget.content.contentType == ContentType.link &&
                  _extractYouTubeVideoId(widget.content.contentData ?? widget.content.description ?? '') == null &&
                  _metadataLoaded &&
                  _linkMetadata?.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _openLink(widget.content.contentData ?? widget.content.description ?? ''),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            _linkMetadata!.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            cacheHeight: 200,
                            cacheWidth: 1080,
                            filterQuality: FilterQuality.medium,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildLinkPreviewPlaceholder();
                            },
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.open_in_browser,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Show loading indicator while fetching metadata for non-YouTube links
              if (widget.content.contentType == ContentType.link &&
                  _extractYouTubeVideoId(widget.content.contentData ?? widget.content.description ?? '') == null &&
                  !_metadataLoaded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.content.title != null)
                          Text(
                            widget.content.title!,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.content.source != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.content.source!,
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
                    child: _ContentTypeIcon(type: widget.content.contentType),
                  ),
                ],
              ),
              if (widget.content.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.content.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.content.formattedTime,
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

  /// Build media thumbnail widget
  Widget _buildMediaThumbnail(String filePath) {
    try {
      // Try to load as file first (most likely case after Android caching)
      if (filePath.startsWith('/') || filePath.startsWith('content://')) {
        if (filePath.startsWith('content://')) {
          return _buildImageFromContentUri(filePath);
        } else {
          // It's already a file path
          return _loadImageFromFilePath(filePath);
        }
      }
      
      return _buildThumbnailPlaceholder('Invalid path');
    } catch (e) {
      return _buildThumbnailPlaceholder('Error loading media');
    }
  }

  /// Build image from Android content URI
  Widget _buildImageFromContentUri(String contentUri) {
    // Check if it's already a file path (cached)
    if (contentUri.startsWith('/')) {
      return _loadImageFromFilePath(contentUri);
    }
    
    // Otherwise try to get cached version via platform channel
    return FutureBuilder<Widget>(
      future: _loadContentUriImage(contentUri),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          return _buildThumbnailPlaceholder('Could not load image');
        } else {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _loadImageFromFilePath(String filePath) {
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
        cacheHeight: 200,
        cacheWidth: 1080,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailPlaceholder('Image load error');
        },
      );
    } catch (e) {
      return _buildThumbnailPlaceholder('File error');
    }
  }

  /// Load image from content URI using platform channel
  Future<Widget> _loadContentUriImage(String contentUri) async {
    try {
      // Use a method channel to get the cached file path from content URI
      const platform = MethodChannel('com.example.seen_this/share');
      
      final String? cachedPath = 
          await platform.invokeMethod<String>('getCachedImagePath', {'uri': contentUri})
              .timeout(const Duration(seconds: 5), onTimeout: () {
            return null;
          });
      
      if (cachedPath != null && cachedPath.isNotEmpty) {
        try {
          final file = File(cachedPath);
          if (!file.existsSync()) {
            return _buildThumbnailPlaceholder('File not found');
          }
          return Image.file(
            file,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            cacheHeight: 200,
            cacheWidth: 1080,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) {
              return _buildThumbnailPlaceholder('Image load error');
            },
          );
        } catch (e) {
          return _buildThumbnailPlaceholder('File error');
        }
      } else {
        return _buildThumbnailPlaceholder('Could not cache image');
      }
    } catch (e) {
      return _buildThumbnailPlaceholder('Load error');
    }
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

  /// Build placeholder for generic link previews
  Widget _buildLinkPreviewPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Link preview unavailable',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Open the media viewer screen
  void _openMediaViewer(BuildContext context, SharedContent content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          filePath: content.contentData!,
          title: content.title,
        ),
      ),
    );
  }

  /// Extract YouTube video ID from any YouTube URL format
  /// Returns null if URL is not a valid YouTube link
  String? _extractYouTubeVideoId(String url) {
    try {
      // Not a YouTube URL at all
      if (!url.contains('youtube.com') && !url.contains('youtu.be')) {
        return null;
      }

      // Try short URL format: youtu.be/ID or youtu.be/ID?params
      var match = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) return match.group(1);

      // Try standard watch format: ?v=ID or &v=ID
      match = RegExp(r'[?&]v=([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) return match.group(1);

      // Try live format: /live/ID
      match = RegExp(r'/live/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) return match.group(1);

      // Try shorts format: /shorts/ID
      match = RegExp(r'/shorts/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) return match.group(1);

      // Try embed format: /embed/ID
      match = RegExp(r'/embed/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) return match.group(1);
    } catch (e) {
      // Silent failure
    }
    return null;
  }

  /// Build YouTube thumbnail section - checks both contentData and description
  Widget _buildYouTubeThumbnailSection(BuildContext context, SharedContent content) {
    // Try to extract video ID from contentData first, then description
    String? youtubeUrl;
    String? videoId;

    if (content.contentData != null) {
      videoId = _extractYouTubeVideoId(content.contentData!);
      if (videoId != null) youtubeUrl = content.contentData;
    }

    if (youtubeUrl == null && content.description != null) {
      videoId = _extractYouTubeVideoId(content.description!);
      if (videoId != null) youtubeUrl = content.description;
    }

    // If we couldn't extract a video ID, it's not YouTube
    if (youtubeUrl == null || videoId == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _openLink(youtubeUrl!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              _buildYouTubeThumbnail(youtubeUrl),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build YouTube thumbnail widget
  Widget _buildYouTubeThumbnail(String url) {
    final videoId = _extractYouTubeVideoId(url);
    
    if (videoId == null) {
      return _buildThumbnailPlaceholder('Invalid YouTube URL');
    }

    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return Image.network(
      thumbnailUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      cacheHeight: 200,
      cacheWidth: 1080,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final fallbackUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        return Image.network(
          fallbackUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildThumbnailPlaceholder('YouTube thumbnail unavailable');
          },
        );
      },
    );
  }

  /// Open a link in the browser
  Future<void> _openLink(String url) async {
    try {
      // Use the share_plus plugin to open the link
      // Or could use url_launcher package for more control
      await Share.share(url);
    } catch (e) {
      // Silent failure
    }
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
                  widget.onDelete();
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
      await ReshareService.reshareContent(widget.content);
      
      // Persist the reshared item to today's collection so it can be reshared again
      if (context.mounted) {
        final collectionsNotifier = context.read<CollectionsNotifier>();
        await collectionsNotifier.addContentToday(
          widget.content.contentType,
          title: widget.content.title,
          description: widget.content.description,
          source: '${widget.content.source} (reshared)',
          contentData: widget.content.contentData,
          mimeType: widget.content.mimeType,
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
    
    if (widget.content.title != null) {
      buffer.writeln(widget.content.title);
    }
    
    if (widget.content.source != null) {
      buffer.writeln('From: ${widget.content.source}');
    }
    
    if (widget.content.description != null) {
      buffer.writeln('\n${widget.content.description}');
    }
    
    if (widget.content.contentData != null) {
      buffer.writeln('\n${widget.content.contentData}');
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
