/// Sort options for displaying shares
enum SortBy {
  newestFirst('Newest First', 'Sort by most recent'),
  oldestFirst('Oldest First', 'Sort by least recent'),
  titleAZ('Title A-Z', 'Sort alphabetically'),
  titleZA('Title Z-A', 'Sort reverse alphabetically');

  final String label;
  final String description;

  const SortBy(this.label, this.description);

  /// Get readable display name
  String get displayName => label;
}
