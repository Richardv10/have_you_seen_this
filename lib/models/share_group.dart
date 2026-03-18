import 'package:uuid/uuid.dart';

/// Represents a contact in a share group
class GroupContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;

  GroupContact({
    String? id,
    required this.name,
    required this.phoneNumber,
    this.email,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory GroupContact.fromJson(Map<String, dynamic> json) {
    return GroupContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
    );
  }

  GroupContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
  }) {
    return GroupContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

/// Represents a group of contacts for batch sharing
class ShareGroup {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<GroupContact> contacts;
  final String? color; // Hex color for display

  ShareGroup({
    String? id,
    required this.name,
    this.description,
    DateTime? createdAt,
    this.contacts = const [],
    this.color,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'color': color,
    };
  }

  /// Create from JSON
  factory ShareGroup.fromJson(Map<String, dynamic> json) {
    return ShareGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((c) => GroupContact.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      color: json['color'] as String?,
    );
  }

  /// Create a copy with modifications
  ShareGroup copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<GroupContact>? contacts,
    String? color,
  }) {
    return ShareGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      contacts: contacts ?? this.contacts,
      color: color ?? this.color,
    );
  }

  /// Add a contact to this group
  ShareGroup withContact(GroupContact contact) {
    if (contacts.any((c) => c.id == contact.id)) return this;
    return copyWith(contacts: [...contacts, contact]);
  }

  /// Remove a contact from this group
  ShareGroup withoutContact(String contactId) {
    return copyWith(
      contacts: contacts.where((c) => c.id != contactId).toList(),
    );
  }
}
