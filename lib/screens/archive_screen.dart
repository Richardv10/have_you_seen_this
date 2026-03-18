import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../widgets/content_card.dart';

/// Screen displaying archived content grouped by date
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  SortBy _currentSort = SortBy.newestFirst;

  @override
  void initState() {
    super.initState();
    _loadSortPreference();
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final sortIndex = prefs.getInt('archive_sort_preference') ?? 0;
    setState(() {
      _currentSort = SortBy.values[sortIndex];
    });
  }

  Future<void> _saveSortPreference(SortBy sortBy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('archive_sort_preference', sortBy.index);
  }

  List<DailyCollection> _applySorting(List<DailyCollection> collections) {
    final sorted = List<DailyCollection>.from(collections);

    switch (_currentSort) {
      case SortBy.newestFirst:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.oldestFirst:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortBy.titleAZ:
        sorted.sort((a, b) {
          final titleA = a.items.isNotEmpty ? a.items.first.title : '';
          final titleB = b.items.isNotEmpty ? b.items.first.title : '';
          return (titleA ?? '').toLowerCase().compareTo((titleB ?? '').toLowerCase());
        });
        break;
      case SortBy.titleZA:
        sorted.sort((a, b) {
          final titleA = a.items.isNotEmpty ? a.items.first.title : '';
          final titleB = b.items.isNotEmpty ? b.items.first.title : '';
          return (titleB ?? '').toLowerCase().compareTo((titleA ?? '').toLowerCase());
        });
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsNotifier>(
      builder: (context, collectionsNotifier, child) {
        final collections = collectionsNotifier.collections;

        // Filter out today if present
        var archiveCollections =
            collections.where((c) => !c.isToday).toList();

        // Apply sorting
        archiveCollections = _applySorting(archiveCollections);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Archive'),
            elevation: 0,
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<SortBy>(
                  onSelected: (sortBy) {
                    setState(() {
                      _currentSort = sortBy;
                    });
                    _saveSortPreference(sortBy);
                  },
                  itemBuilder: (BuildContext context) => SortBy.values
                      .map((sort) => PopupMenuItem<SortBy>(
                            value: sort,
                            child: Row(
                              children: [
                                if (_currentSort == sort)
                                  const Icon(Icons.check, size: 20)
                                else
                                  const SizedBox(width: 20),
                                const SizedBox(width: 12),
                                Text(sort.label),
                              ],
                            ),
                          ))
                      .toList(),
                  child: const Icon(Icons.sort),
                ),
              ),
            ],
          ),
          body: archiveCollections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No archived shares',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: archiveCollections.length,
                  itemBuilder: (context, index) {
                    final collection = archiveCollections[index];
                    return _DaySection(
                      collection: collection,
                      onRemoveItem: (contentId) {
                        collectionsNotifier.removeContent(
                          collection.date,
                          contentId,
                        );
                      },
                      onDeleteDay: () {
                        collectionsNotifier.deleteCollection(collection.date);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  final DailyCollection collection;
  final Function(String) onRemoveItem;
  final VoidCallback onDeleteDay;

  const _DaySection({
    required this.collection,
    required this.onRemoveItem,
    required this.onDeleteDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                collection.formattedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Delete all'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...collection.items.map(
          (content) => Padding(
            key: ValueKey(content.id),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ContentCard(
              key: ValueKey('content_${content.id}'),
              content: content,
              onDelete: () => onRemoveItem(content.id),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete all?'),
          content: Text(
            'Are you sure you want to delete all items from ${collection.shortDate}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDeleteDay();
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
