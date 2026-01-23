import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/collections_notifier.dart';
import '../widgets/content_card.dart';

/// Screen displaying today's shared content
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late String _randomPhrase;
  
  static final Random _random = Random();
  
  static const List<String> _phrases = [
    'Feed me memes!',
    'I\'m content just sat here, get it?',
    'I\'m sure it\'s super important',
    'Show me what you got!',
    'Send to lovers, send to haters',
    'Got anything good today?',
    'This isn\'t going to everybody, right?',
    'Yes, yes I can\'t believe it either',
    'What you got for me?',
    'Make my day baby!',
  ];

  @override
  void initState() {
    super.initState();
    _randomPhrase = _phrases[_random.nextInt(_phrases.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsNotifier>(
      builder: (context, collectionsNotifier, child) {
        final todayCollection = collectionsNotifier.todayCollection;
        final items = todayCollection?.items ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('From Today'),
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
                        _randomPhrase,
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
                    final item = items[index];
                    return ContentCard(
                      key: ValueKey('content_${item.id}'),
                      content: item,
                      onDelete: () {
                        collectionsNotifier.removeContent(
                          todayCollection!.date,
                          item.id,
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

