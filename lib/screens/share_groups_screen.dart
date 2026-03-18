import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/share_group_notifier.dart';
import '../services/share_history_service.dart';

/// Screen for managing share groups
class ShareGroupsScreen extends StatelessWidget {
  const ShareGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Groups'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ShareGroupNotifier>(
        builder: (context, shareGroupNotifier, child) {
          final groups = shareGroupNotifier.groups;

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_shared_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No share groups yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a group to organize your shared content',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateGroupDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Group'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _GroupCard(
                group: group,
                onEdit: () => _showEditGroupDialog(context, group),
                onDelete: () => _showDeleteConfirmation(context, group),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        tooltip: 'Create Group',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Show dialog to create a new group
  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g., Work, Personal, Ideas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'What is this group for?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a group name')),
                  );
                  return;
                }

                final shareGroupNotifier =
                    context.read<ShareGroupNotifier>();
                shareGroupNotifier.createGroup(
                  name: nameController.text,
                  description: descriptionController.text,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Group "${nameController.text}" created'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to edit a group
  void _showEditGroupDialog(BuildContext context, ShareGroup group) {
    final nameController = TextEditingController(text: group.name);
    final descriptionController =
        TextEditingController(text: group.description ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            title: const Text('Edit Group'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Members'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Details tab
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Group Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description (optional)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        // Members tab
                        _MembersTab(group: group),
                      ],
                    ),
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
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a group name')),
                    );
                    return;
                  }

                  final shareGroupNotifier =
                      context.read<ShareGroupNotifier>();
                  final updatedGroup = group.copyWith(
                    name: nameController.text,
                    description: descriptionController.text,
                  );
                  shareGroupNotifier.updateGroup(updatedGroup);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, ShareGroup group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Group?'),
          content: Text(
            'Are you sure you want to delete "${group.name}"? This will not affect any existing shares.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final shareGroupNotifier =
                    context.read<ShareGroupNotifier>();
                shareGroupNotifier.deleteGroup(group.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Group "${group.name}" deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// Widget for displaying a single group card
class _GroupCard extends StatelessWidget {
  final ShareGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if ((group.description ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              group.description ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.contacts,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.contacts.length} contact${group.contacts.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for managing group members
class _MembersTab extends StatefulWidget {
  final ShareGroup group;

  const _MembersTab({required this.group});

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  @override
  Widget build(BuildContext context) {
    final shareHistoryService = context.read<ShareHistoryService>();
    final availableContacts = shareHistoryService.getUniqueRecipients();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Members (${widget.group.contacts.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (widget.group.contacts.isEmpty)
                  Text(
                    'No members yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  )
                else
                  Column(
                    children: widget.group.contacts
                        .map(
                          (contact) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(contact.name),
                            subtitle: Text(contact.phoneNumber),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                context
                                    .read<ShareGroupNotifier>()
                                    .removeContactFromGroup(
                                      widget.group.id,
                                      contact.id,
                                    );
                                // Refresh UI
                                setState(() {});
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add from Share History',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (availableContacts.isEmpty)
                  Text(
                    'Share something first to add recipients',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  )
                else
                  Column(
                    children: availableContacts
                        .map(
                          (contact) {
                            final isAlreadyMember = widget.group.contacts
                                .any((c) => c.phoneNumber == contact.phoneNumber);
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(contact.name),
                              subtitle: Text(contact.phoneNumber),
                              trailing: isAlreadyMember
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () {
                                        context
                                            .read<ShareGroupNotifier>()
                                            .addContactToGroup(
                                              widget.group.id,
                                              contact,
                                            );
                                        // Refresh UI
                                        setState(() {});
                                      },
                                    ),
                            );
                          },
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
