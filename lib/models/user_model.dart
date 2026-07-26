import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // 'customer', 'admin', 'superadmin'
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.role = 'customer',
    this.createdAt,
  });

  /// Check if user has Admin or Superadmin privileges (case-insensitive & trimmed)
  bool get isAdmin {
    final cleanRole = role.trim().toLowerCase();
    return cleanRole == 'admin' || cleanRole == 'superadmin';
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Robust parsing for role
    final rawRole = data['role']?.toString().trim() ?? 'customer';

    return UserModel(
      id: doc.id,
      name: data['nama'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['no_hp'] ?? data['phoneNumber'] ?? '',
      role: rawRole,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': name,
      'email': email,
      'no_hp': phoneNumber,
      'role': role,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
