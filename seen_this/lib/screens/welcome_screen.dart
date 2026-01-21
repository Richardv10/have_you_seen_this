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
              // Icon/Title
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Welcome to: Have You Seen This?',
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
                title: 'Share Content',
                description: 'Select the app from your phones share menu',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.calendar_today,
                title: 'Organize by Day',
                description: 'All content is organized into daily collections',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.archive,
                title: 'Archive Old Items',
                description: 'Move items to Archive when you\'re done with them',
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.share_rounded,
                title: 'Share Again',
                description: 'Easily re-share and group share',
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
