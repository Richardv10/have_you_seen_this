import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/collections_notifier.dart';
import '../services/share_intent_service.dart';
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
                        'Use the + button below to add test content',
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddContentDialog(context, collectionsNotifier),
            tooltip: 'Add test content or screenshot',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  void _showAddContentDialog(
    BuildContext context,
    CollectionsNotifier collectionsNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Add Test Content'),
              onTap: () {
                Navigator.pop(context);
                _showTestContentDialog(context, collectionsNotifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Simulate Screenshot (Windows only)'),
              onTap: () {
                Navigator.pop(context);
                ShareIntentService.addTestContent(
                  collectionsNotifier,
                  ContentType.screenshot,
                  title: 'Screenshot',
                  description: 'Simulated screenshot from device',
                  source: 'Screenshot',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTestContentDialog(
    BuildContext context,
    CollectionsNotifier collectionsNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddContentDialog(
        onAddContent: (type, title, description) async {
          await ShareIntentService.addTestContent(
            collectionsNotifier,
            type,
            title: title.isNotEmpty ? title : null,
            description: description.isNotEmpty ? description : null,
          );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

class _AddContentDialog extends StatefulWidget {
  final Function(ContentType, String, String) onAddContent;

  const _AddContentDialog({required this.onAddContent});

  @override
  State<_AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<_AddContentDialog> {
  ContentType _selectedType = ContentType.link;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Test Content'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<ContentType>(
              value: _selectedType,
              isExpanded: true,
              items: ContentType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    ),
                  )
                  .toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() => _selectedType = type);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onAddContent(
            _selectedType,
            _titleController.text,
            _descriptionController.text,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

