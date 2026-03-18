import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/share_group.dart';

/// Service for tracking share history - people who have received shares
class ShareHistoryService {
  static const String _historyKey = 'share_history';
  late SharedPreferences _prefs;
  List<GroupContact> _history = [];

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHistory();
  }

  /// Load history from storage
  Future<void> _loadHistory() async {
    try {
      final jsonStr = _prefs.getString(_historyKey);
      if (jsonStr == null) {
        _history = [];
      } else {
        final jsonList = jsonDecode(jsonStr) as List<dynamic>;
        _history = jsonList
            .map((item) => GroupContact.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading share history: $e');
      _history = [];
    }
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      final jsonList = _history.map((c) => c.toJson()).toList();
      await _prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      // ignore: avoid_print
      print('Error saving share history: $e');
    }
  }

  /// Get all recipients from history
  List<GroupContact> getHistory() => List.from(_history);

  /// Add a recipient to history if not already present
  Future<void> addRecipient(String name, String phoneNumber,
      {String? email}) async {
    // Check if already in history
    final exists = _history.any((c) => c.phoneNumber == phoneNumber);
    if (exists) {
      return; // Already tracked
    }

    final contact = GroupContact(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
    );

    _history.add(contact);
    await _saveHistory();
  }

  /// Get unique recipients by phone number (deduped)
  List<GroupContact> getUniqueRecipients() {
    final seen = <String>{};
    final unique = <GroupContact>[];

    for (final contact in _history) {
      if (!seen.contains(contact.phoneNumber)) {
        seen.add(contact.phoneNumber);
        unique.add(contact);
      }
    }

    return unique;
  }

  /// Clear history (optional)
  Future<void> clearHistory() async {
    _history = [];
    await _saveHistory();
  }
}
