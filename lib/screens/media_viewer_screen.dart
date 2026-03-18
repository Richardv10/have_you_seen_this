import 'package:flutter/material.dart';
import 'dart:io';

/// Full-screen media viewer for images and videos
class MediaViewerScreen extends StatelessWidget {
  final String filePath;
  final String? title;

  const MediaViewerScreen({
    super.key,
    required this.filePath,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideo(filePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Media'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: isVideo
              ? _buildVideoPlaceholder()
              : _buildImageViewer(),
        ),
      ),
    );
  }

  bool _isVideo(String path) {
    final extension = path.toLowerCase().split('.').last;
    final videoExtensions = ['mp4', 'mkv', 'webm', 'avi', 'mov', 'flv', 'wmv'];
    return videoExtensions.contains(extension);
  }

  Widget _buildImageViewer() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'File not found',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      }

      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[600]),
                const SizedBox(height: 16),
                const Text(
                  'Could not load image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[600]),
          const SizedBox(height: 16),
          Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  Widget _buildVideoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.video_library,
          size: 96,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 24),
        const Text(
          'Video Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Video playback coming soon',
          style: TextStyle(color: Colors.grey[400]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            filePath.split('/').last,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
