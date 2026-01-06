import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
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

  /// Share the content using system share dialog
  Future<void> _shareContent() async {
    final shareText = _buildShareText();
    await Share.share(shareText);
  }

  /// Copy content to clipboard
  void _copyToClipboard(BuildContext context) {
    final text = _buildShareText();
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
