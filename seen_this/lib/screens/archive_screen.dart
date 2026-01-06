import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../widgets/content_card.dart';

/// Screen displaying archived content grouped by date
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsNotifier>(
      builder: (context, collectionsNotifier, child) {
        final collections = collectionsNotifier.collections;

        // Filter out today if present
        final archiveCollections =
            collections.where((c) => !c.isToday).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Archive'),
            elevation: 0,
            centerTitle: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ContentCard(
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
