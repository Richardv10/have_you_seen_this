import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

/// Service for managing share groups (groups of contacts for batch sharing)
class ShareGroupService {
  static const String _groupsKey = 'share_groups';
  late SharedPreferences _prefs;
  List<ShareGroup> _groups = [];

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadGroups();
  }

  /// Load groups from storage
  Future<void> _loadGroups() async {
    try {
      final jsonStr = _prefs.getString(_groupsKey);
      if (jsonStr == null) {
        _groups = [];
      } else {
        final jsonList = jsonDecode(jsonStr) as List<dynamic>;
        _groups = jsonList
            .map((item) => ShareGroup.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading groups: $e');
      _groups = [];
    }
  }

  /// Save groups to storage
  Future<void> _saveGroups() async {
    try {
      final jsonList = _groups.map((g) => g.toJson()).toList();
      await _prefs.setString(_groupsKey, jsonEncode(jsonList));
    } catch (e) {
      // ignore: avoid_print
      print('Error saving groups: $e');
    }
  }

  /// Get all groups
  List<ShareGroup> getGroups() => List.from(_groups);

  /// Get group by ID
  ShareGroup? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new group with optional initial contacts
  Future<ShareGroup> createGroup({
    required String name,
    String? description,
    String? color,
    List<GroupContact> contacts = const [],
  }) async {
    final group = ShareGroup(
      name: name,
      description: description,
      color: color,
      contacts: contacts,
    );
    _groups.add(group);
    await _saveGroups();
    return group;
  }

  /// Update a group
  Future<void> updateGroup(ShareGroup group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      await _saveGroups();
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
    await _saveGroups();
  }

  /// Add a contact to a group
  Future<void> addContactToGroup(String groupId, GroupContact contact) async {
    final group = getGroupById(groupId);
    if (group != null) {
      await updateGroup(group.withContact(contact));
    }
  }

  /// Remove a contact from a group
  Future<void> removeContactFromGroup(String groupId, String contactId) async {
    final group = getGroupById(groupId);
    if (group != null) {
      await updateGroup(group.withoutContact(contactId));
    }
  }

  /// Get all contacts in a group
  List<GroupContact> getGroupContacts(String groupId) {
    final group = getGroupById(groupId);
    return group?.contacts ?? [];
  }
}
