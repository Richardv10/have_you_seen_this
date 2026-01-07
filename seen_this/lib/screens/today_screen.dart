import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../widgets/content_card.dart';

/// Screen displaying today's shared content
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsNotifier>(
      builder: (context, collectionsNotifier, child) {
        final todayCollection = collectionsNotifier.todayCollection;
        final items = todayCollection?.items ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Today\'s Shares'),
            elevation: 0,
            centerTitle: true,
          ),
          body: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No shares yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share content from other apps to add it here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ContentCard(
                      content: items[index],
                      onDelete: () {
                        collectionsNotifier.removeContent(
                          todayCollection!.date,
                          items[index].id,
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

