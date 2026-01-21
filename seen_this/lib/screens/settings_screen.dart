import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collections_notifier.dart';
import '../providers/theme_notifier.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              return ListTile(
                title: const Text('Dark Mode'),
                leading: const Icon(Icons.dark_mode_outlined),
                trailing: Switch(
                  value: themeNotifier.isDarkMode,
                  onChanged: (_) => themeNotifier.toggleTheme(),
                ),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('seen_this'),
            subtitle: const Text('v1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Data',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Clear all data'),
            subtitle: const Text('Delete all saved shares'),
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () => _showClearConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear all data?'),
          content: const Text(
            'This will permanently delete all your saved shares. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final notifier = context.read<CollectionsNotifier>();
                await notifier.deleteCollection(DateTime.now());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data cleared')),
                  );
                }
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
