import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/share_group_service.dart';

/// Provider for managing share groups (groups of contacts for batch sharing)
class ShareGroupNotifier extends ChangeNotifier {
  final ShareGroupService _service;
  List<ShareGroup> _groups = [];

  ShareGroupNotifier(this._service);

  // Getters
  List<ShareGroup> get groups => List.from(_groups);

  /// Initialize and load groups
  Future<void> init() async {
    await _service.init();
    _groups = _service.getGroups();
    notifyListeners();
  }

  /// Create a new group
  Future<ShareGroup> createGroup({
    required String name,
    String? description,
    String? color,
    List<GroupContact>? contacts,
  }) async {
    final group = await _service.createGroup(
      name: name,
      description: description,
      color: color,
      contacts: contacts ?? [],
    );
    _groups = _service.getGroups();
    notifyListeners();
    return group;
  }

  /// Update a group
  Future<void> updateGroup(ShareGroup group) async {
    await _service.updateGroup(group);
    _groups = _service.getGroups();
    notifyListeners();
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroup(groupId);
    _groups = _service.getGroups();
    notifyListeners();
  }

  /// Add a contact to a group
  Future<void> addContactToGroup(String groupId, GroupContact contact) async {
    await _service.addContactToGroup(groupId, contact);
    _groups = _service.getGroups();
    notifyListeners();
  }

  /// Remove a contact from a group
  Future<void> removeContactFromGroup(
    String groupId,
    String contactId,
  ) async {
    await _service.removeContactFromGroup(groupId, contactId);
    _groups = _service.getGroups();
    notifyListeners();
  }

  /// Get contacts in a group
  List<GroupContact> getGroupContacts(String groupId) {
    return _service.getGroupContacts(groupId);
  }
}
