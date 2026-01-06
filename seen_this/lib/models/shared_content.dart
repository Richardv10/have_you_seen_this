import 'package:intl/intl.dart';

enum ContentType {
  screenshot,
  link,
  text,
  media,
  other,
}

/// Represents a single piece of shared content
class SharedContent {
  final String id;
  final ContentType contentType;
  final String? title;
  final String? description;
  final DateTime timestamp;
  final String? source; // e.g., "Instagram", "Twitter", "Clipboard"
  final String? contentData; // URL, text content, file path, etc.
  final String? mimeType;

  SharedContent({
    required this.id,
    required this.contentType,
    this.title,
    this.description,
    required this.timestamp,
    this.source,
    this.contentData,
    this.mimeType,
  });

  /// Format timestamp for display
  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType.toString(),
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'contentData': contentData,
      'mimeType': mimeType,
    };
  }

  /// Create from JSON
  factory SharedContent.fromJson(Map<String, dynamic> json) {
    return SharedContent(
      id: json['id'] as String,
      contentType:
          ContentType.values.firstWhere(
            (e) => e.toString() == json['contentType'],
            orElse: () => ContentType.other,
          ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String?,
      contentData: json['contentData'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  /// Create a copy with modifications
  SharedContent copyWith({
    String? id,
    ContentType? contentType,
    String? title,
    String? description,
    DateTime? timestamp,
    String? source,
    String? contentData,
    String? mimeType,
  }) {
    return SharedContent(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      contentData: contentData ?? this.contentData,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}
