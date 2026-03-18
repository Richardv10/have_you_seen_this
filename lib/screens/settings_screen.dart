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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Theme Color',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ColorTheme.values
                      .map(
                        (theme) => GestureDetector(
                          onTap: () => themeNotifier.setColorTheme(theme),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: theme.colorValue,
                                  shape: BoxShape.circle,
                                  border: themeNotifier.colorTheme == theme
                                      ? Border.all(
                                          color: theme.colorValue,
                                          width: 3,
                                        )
                                      : null,
                                  boxShadow: themeNotifier.colorTheme == theme
                                      ? [
                                          BoxShadow(
                                            color: theme.colorValue.withValues(alpha: 0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: themeNotifier.colorTheme == theme
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                theme.label,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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
            subtitle: const Text('v1.0.0-beta'),
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
