import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onDismiss;

  const WelcomeScreen({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Title
              Text(
                'Welcome to: Seen This?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Keep track of stuff you want to share later',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // How it works
              _InfoTile(
                icon: Icons.share,
                title: 'Share to, and from the app',
                description: 'Select the app from your phones share menu, long press in the app to share',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.calendar_today,
                title: 'Organized by Day',
                description: 'Content is organized into a daily scroll',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.archive,
                title: 'Archive Old Items',
                description: 'Content moves to the Archive automatically',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.share_rounded,
                title: 'Create tags',
                description: 'Label links with quick tags (long press)',
              ),
              const Spacer(),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
