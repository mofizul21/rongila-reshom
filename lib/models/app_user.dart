import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, manager }

class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final DateTime createdAt;
  final String? createdBy;

  AppUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.createdAt,
    this.createdBy,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.manager,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
}
