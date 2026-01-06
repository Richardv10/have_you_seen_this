import 'package:intl/intl.dart';
import 'shared_content.dart';

/// Represents a collection of shared content for a specific date
class DailyCollection {
  final DateTime date;
  final List<SharedContent> items;

  DailyCollection({
    required this.date,
    List<SharedContent>? items,
  }) : items = items ?? [];

  /// Get the date as a formatted string (e.g., "January 6, 2026")
  String get formattedDate {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Get the date as a short string (e.g., "Jan 6")
  String get shortDate {
    return DateFormat('MMM d').format(date);
  }

  /// Check if this is today's collection
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Add a content item
  void addContent(SharedContent content) {
    items.add(content);
    // Sort by timestamp, newest first
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Remove a content item by ID
  void removeContent(String id) {
    items.removeWhere((item) => item.id == id);
  }

  /// Clear all content for this day
  void clear() {
    items.clear();
  }

  /// Get items count
  int get count => items.length;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory DailyCollection.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return DailyCollection(
      date: DateTime.parse(json['date'] as String),
      items: itemsJson
          .map((item) => SharedContent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
